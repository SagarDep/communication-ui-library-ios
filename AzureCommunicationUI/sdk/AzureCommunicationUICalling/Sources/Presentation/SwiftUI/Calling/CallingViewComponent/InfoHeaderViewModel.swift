//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class InfoHeaderViewModel: ObservableObject {
    @Published var accessibilityLabel: String
    @Published var infoLabel: String
    @Published var isRecording: Bool=false
    @Published var isInfoHeaderDisplayed = true
    @Published var isParticipantsListDisplayed = false
    @Published var isParticipantMenuDisplayed = false
    @Published var isVoiceOverEnabled = false
    private let logger: Logger
    private let dispatch: ActionDispatch
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private var infoHeaderDismissTimer: Timer?
    private var participantsCount: Int = 0
    private var callingStatus: CallingStatus = .none
    let enableMultitasking: Bool
    private let enableSystemPipWhenMultitasking: Bool

    let participantsListViewModel: ParticipantsListViewModel
    let participantMenuViewModel: ParticipantMenuViewModel
    var participantListButtonViewModel: IconButtonViewModel!
    var dismissButtonViewModel: IconButtonViewModel!

    var isPad = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         dispatchAction: @escaping ActionDispatch,
         enableMultitasking: Bool,
         enableSystemPipWhenMultitasking: Bool) {
        self.dispatch = dispatchAction
        self.logger = logger
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        let title = localizationProvider.getLocalizedString(.callWith0Person)
        self.infoLabel = title
        self.accessibilityLabel = title
        self.enableMultitasking = enableMultitasking
        self.enableSystemPipWhenMultitasking = enableSystemPipWhenMultitasking
        self.participantMenuViewModel = compositeViewModelFactory.makeParticipantMenuViewModel(
            localUserState: localUserState,
            dispatchAction: dispatchAction)
        self.participantsListViewModel = compositeViewModelFactory.makeParticipantsListViewModel(
            localUserState: localUserState, dispatchAction: dispatchAction)
        self.participantListButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .showParticipant,
            buttonType: .infoButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.showParticipantListButtonTapped()
                
                
              
        }
        self.participantsListViewModel.displayParticipantMenu = self.displayParticipantMenu
        self.participantListButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .participantListAccessibilityLabel)

        dismissButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .leftArrow,
            buttonType: .infoButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.dismissButtonTapped()
        }
        dismissButtonViewModel.update(
            accessibilityLabel: self.localizationProvider.getLocalizedString(.dismissAccessibilityLabel))

        self.accessibilityProvider.subscribeToVoiceOverStatusDidChangeNotification(self)
        self.accessibilityProvider.subscribeToUIFocusDidUpdateNotification(self)
        updateInfoHeaderAvailability()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateRecording(_: )), name: NSNotification.Name(rawValue: "updateRecording"), object: nil)
    }

    
    @objc private func updateRecording(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let value = userInfo["value"] as? Bool {
           
            self.isRecording = value
         
        }
    }
    func showParticipantListButtonTapped() {
        logger.debug("Show participant list button tapped")
        if isPad {
            self.infoHeaderDismissTimer?.invalidate()
        }
        self.displayParticipantsList()
    }

    func displayParticipantsList() {
        self.isParticipantsListDisplayed = true
    }

    func displayParticipantMenu(participantId: String, participantDisplayName: String) {
        participantMenuViewModel.showMenu(participantId: participantId, participantDisplayName: participantDisplayName)
        self.isParticipantMenuDisplayed = true
    }

    func toggleDisplayInfoHeaderIfNeeded() {
        guard !isVoiceOverEnabled else {
            return
        }
        if self.isInfoHeaderDisplayed {
            hideInfoHeader()
        } else {
            displayWithTimer()
        }
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState,
                callingState: CallingState,
                visibilityState: VisibilityState) {
        isHoldingCall(callingState: callingState)
        let shouldDisplayInfoHeaderValue = shouldDisplayInfoHeader(for: callingStatus)
        let newDisplayInfoHeaderValue = shouldDisplayInfoHeader(for: callingState.status)
        callingStatus = callingState.status
        if isVoiceOverEnabled && newDisplayInfoHeaderValue != shouldDisplayInfoHeaderValue {
            updateInfoHeaderAvailability()
        }

        let updatedRemoteparticipantCount = getParticipantCount(remoteParticipantsState)

        if participantsCount != updatedRemoteparticipantCount {
            participantsCount = updatedRemoteparticipantCount
            updateInfoLabel()
        }
        participantsListViewModel.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        participantMenuViewModel.update(localUserState: localUserState)

        if visibilityState.currentStatus == .pipModeEntered {
            hideInfoHeader()
        }

        if visibilityState.currentStatus != .visible {
            isParticipantsListDisplayed = false
        }
    }

    private func getParticipantCount(_ remoteParticipantsState: RemoteParticipantsState) -> Int {
        let remoteParticipantCountForGridView = remoteParticipantsState.participantInfoList
            .filter({ participantInfoModel in
                participantInfoModel.status != .inLobby && participantInfoModel.status != .disconnected
            })
            .count

        let filteredOutRemoteParticipantsCount =
        remoteParticipantsState.participantInfoList.count - remoteParticipantCountForGridView

        return remoteParticipantsState.totalParticipantCount - filteredOutRemoteParticipantsCount
    }

    private func isHoldingCall(callingState: CallingState) {
        guard callingState.status == .localHold,
              callingStatus != callingState.status else {
            return
        }
        if isInfoHeaderDisplayed {
            isInfoHeaderDisplayed = false
        }
        if isParticipantsListDisplayed {
            isParticipantsListDisplayed = false
        }
    }

    private func updateInfoLabel() {
        let content: String
        switch participantsCount {
        case 0:
            content = localizationProvider.getLocalizedString(.callWith0Person)
        case 1:
            content = localizationProvider.getLocalizedString(.callWith1Person)
        default:
            content = localizationProvider.getLocalizedString(.callWithNPerson, participantsCount)
        }
        infoLabel = content
        accessibilityLabel = content
    }

    private func displayWithTimer() {
        self.isInfoHeaderDisplayed = true
        resetTimer()
    }

    @objc private func hideInfoHeader() {
        self.isInfoHeaderDisplayed = false
        self.infoHeaderDismissTimer?.invalidate()
    }

    private func resetTimer() {
        self.infoHeaderDismissTimer = Timer.scheduledTimer(withTimeInterval: 3.0,
                             repeats: false) { [weak self] _ in
            self?.hideInfoHeader()
        }
    }

    private func updateInfoHeaderAvailability() {
        let shouldDisplayInfoHeader = shouldDisplayInfoHeader(for: callingStatus)
        isVoiceOverEnabled = accessibilityProvider.isVoiceOverEnabled
        // invalidating timer is required for setting the next timer and when VoiceOver is enabled
        infoHeaderDismissTimer?.invalidate()
        if self.isVoiceOverEnabled {
            isInfoHeaderDisplayed = shouldDisplayInfoHeader
        } else if shouldDisplayInfoHeader {
            displayWithTimer()
        }
    }

    private func shouldDisplayInfoHeader(for callingStatus: CallingStatus) -> Bool {
        return callingStatus != .inLobby && callingStatus != .localHold
    }

    private func dismissButtonTapped() {
        if self.enableSystemPipWhenMultitasking {
            dispatch(.visibilityAction(.pipModeRequested))
        } else if self.enableMultitasking {
            dispatch(.visibilityAction(.hideRequested))
        }
    }
    deinit {
           // Remove observer when ViewModel is deallocated
           NotificationCenter.default.removeObserver(self)
       }
}

extension InfoHeaderViewModel: AccessibilityProviderNotificationsObserver {
    func didUIFocusUpdateNotification(_ notification: NSNotification) {
        updateInfoHeaderAvailability()
    }

    func didChangeVoiceOverStatus(_ notification: NSNotification) {
        guard isVoiceOverEnabled != accessibilityProvider.isVoiceOverEnabled else {
            return
        }

        updateInfoHeaderAvailability()
    }
}
