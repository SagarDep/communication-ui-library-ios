//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import Foundation

protocol CompositeViewModelFactoryProtocol {
    // MARK: CompositeViewModels
    func getSetupViewModel() -> SetupViewModel
    func getCallingViewModel(eventButtonClick:((_ event:String) -> Void)?   ,listButtonClick:(() -> Void)? ) -> CallingViewModel
    // MARK: ComponentViewModels
    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel
    func makeIconWithLabelButtonViewModel<ButtonStateType>(
        selectedButtonState: ButtonStateType,
        localizationProvider: LocalizationProviderProtocol,
        buttonTypeColor: IconWithLabelButtonViewModel<ButtonStateType>.ButtonTypeColor,
        isDisabled: Bool,
        action: @escaping (() -> Void)) -> IconWithLabelButtonViewModel<ButtonStateType>
    func makeLocalVideoViewModel(dispatchAction: @escaping ActionDispatch) -> LocalVideoViewModel
    func makePrimaryButtonViewModel(buttonStyle: FluentUI.ButtonStyle,
                                    buttonLabel: String,
                                    iconName: CompositeIcon?,
                                    isDisabled: Bool,
                                    paddings: CompositeButton.Paddings?,
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel
    func makeAudioDevicesListViewModel(dispatchAction: @escaping ActionDispatch,
                                       localUserState: LocalUserState) -> AudioDevicesListViewModel
    func makeErrorInfoViewModel(title: String,
                                subtitle: String) -> ErrorInfoViewModel
    // MARK: CallingViewModels
    func makeLobbyOverlayViewModel() -> LobbyOverlayViewModel
    func makeLoadingOverlayViewModel() -> LoadingOverlayViewModel
    func makeOnHoldOverlayViewModel(resumeAction: @escaping (() -> Void)) -> OnHoldOverlayViewModel
    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 endCallConfirm: @escaping (() -> Void),
                                 localUserState: LocalUserState,
                                 leaveCallConfirmationMode: LeaveCallConfirmationMode,
                                 capabilitiesManager: CapabilitiesManager,
                                 eventButtonClick:((_ event:String) -> Void)? ,
                                 listButtonClick:(() -> Void)?
    ) -> ControlBarViewModel
    func makeInfoHeaderViewModel(dispatchAction: @escaping ActionDispatch,
                                 localUserState: LocalUserState) -> InfoHeaderViewModel
    func makeLobbyWaitingHeaderViewModel(localUserState: LocalUserState,
                                         dispatchAction: @escaping ActionDispatch) -> LobbyWaitingHeaderViewModel
    func makeLobbyActionErrorViewModel(localUserState: LocalUserState,
                                       dispatchAction: @escaping ActionDispatch) -> LobbyErrorHeaderViewModel
    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel,
                                      lifeCycleState: LifeCycleState) -> ParticipantGridCellViewModel
    func makeParticipantGridsViewModel(isIpadInterface: Bool) -> ParticipantGridViewModel
    func makeParticipantsListViewModel(localUserState: LocalUserState,
                                       dispatchAction: @escaping ActionDispatch) -> ParticipantsListViewModel
    func makeParticipantMenuViewModel(localUserState: LocalUserState,
                                      dispatchAction: @escaping ActionDispatch) -> ParticipantMenuViewModel

    func makeBannerViewModel() -> BannerViewModel
    func makeBannerTextViewModel() -> BannerTextViewModel
    func makeLocalParticipantsListCellViewModel(localUserState: LocalUserState) -> ParticipantsListCellViewModel
    func makeParticipantsListCellViewModel(participantInfoModel: ParticipantInfoModel) -> ParticipantsListCellViewModel
    func makeMoreCallOptionsListViewModel(showSharingViewAction: @escaping () -> Void,
                                          showSupportFormAction: @escaping () -> Void, 
                                          eventButtonClick:((_ event:String) -> Void)?  ,
                                          listButtonClick:( () -> Void)? ) -> MoreCallOptionsListViewModel
    func makeDebugInfoSharingActivityViewModel() -> DebugInfoSharingActivityViewModel
    func makeDrawerListItemViewModel(icon: CompositeIcon,
                                     title: String,
                                     accessibilityIdentifier: String,
                                     action:@escaping (() -> Void)) -> DrawerListItemViewModel
    func makeDrawerListItemViewModel(icon: CompositeIcon,
                                     title: String,
                                     accessibilityIdentifier: String) -> DrawerListItemViewModel
    func makeSelectableDrawerListItemViewModel(
        icon: CompositeIcon,
        title: String,
        isSelected: Bool,
        onSelectedAction: @escaping (() -> Void)) -> SelectableDrawerListItemViewModel
    func makeSupportFormViewModel() -> SupportFormViewModel
    func makeCallDiagnosticsViewModel(dispatchAction: @escaping ActionDispatch) -> CallDiagnosticsViewModel
    func makeBottomToastViewModel(toastNotificationState: ToastNotificationState,
                                  dispatchAction: @escaping ActionDispatch) -> BottomToastViewModel
    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel
    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> SetupControlBarViewModel
    func makeJoiningCallActivityViewModel(title: String) -> JoiningCallActivityViewModel
}

extension CompositeViewModelFactoryProtocol {
    func makePrimaryButtonViewModel(buttonStyle: FluentUI.ButtonStyle,
                                    buttonLabel: String,
                                    iconName: CompositeIcon? = .none,
                                    isDisabled: Bool = false,
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel {
        return makePrimaryButtonViewModel(buttonStyle: buttonStyle,
                                          buttonLabel: buttonLabel,
                                          iconName: iconName,
                                          isDisabled: isDisabled,
                                          paddings: nil,
                                          action: action)
    }

    func makeJoiningCallActivityViewModel(title: String) -> JoiningCallActivityViewModel {
        return JoiningCallActivityViewModel(title: title)
    }
}
