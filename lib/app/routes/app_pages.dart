import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../modules/admin_setting_profile/bindings/admin_setting_profile_binding.dart';
import '../modules/admin_setting_profile/views/admin_setting_profile_view.dart';
import '../modules/cafeteria/bindings/cafeteria_binding.dart';
import '../modules/cafeteria/views/cafeteria_view.dart';
import '../modules/cafeteria_add_staff/bindings/cafeteria_add_staff_binding.dart';
import '../modules/cafeteria_add_staff/bindings/cafeteria_edit_staff_binding.dart';
import '../modules/cafeteria_add_staff/views/cafeteria_add_staff_view.dart';
import '../modules/cafeteria_add_staff/views/cafeteria_edit_staff_view.dart';
import '../modules/cafeteria_child_verification/bindings/cafeteria_child_verification_binding.dart';
import '../modules/cafeteria_child_verification/views/cafeteria_child_verification_view.dart';
import '../modules/cafeteria_child_verification_home/bindings/cafeteria_child_verification_home_binding.dart';
import '../modules/cafeteria_child_verification_home/views/cafeteria_child_verification_home_view.dart';
import '../modules/cafeteria_detail/bindings/cafeteria_detail_binding.dart';
import '../modules/cafeteria_detail/views/cafeteria_meal_details_view.dart';
import '../modules/cafeteria_history/bindings/cafeteria_history_binding.dart';
import '../modules/cafeteria_history/views/cafeteria_history_view.dart';
import '../modules/cafeteria_history_details/bindings/cafeteria_history_details_binding.dart';
import '../modules/cafeteria_history_details/views/cafeteria_history_details_view.dart';
import '../modules/cafeteria_history_list/bindings/cafeteria_history_list_binding.dart';
import '../modules/cafeteria_history_list/views/cafeteria_history_list_view.dart';
import '../modules/cafeteria_history_select_date/bindings/cafeteria_history_select_date_binding.dart';
import '../modules/cafeteria_history_select_date/views/cafeteria_history_select_date_view.dart';
import '../modules/cafeteria_home_settings/bindings/cafeteria_home_settings_binding.dart';
import '../modules/cafeteria_home_settings/views/cafeteria_home_settings_view.dart';
import '../modules/cafeteria_landing_page/bindings/cafeteria_landing_page_binding.dart';
import '../modules/cafeteria_landing_page/views/cafeteria_landing_page_view.dart';
import '../modules/cafeteria_meal_details/bindings/cafeteria_meal_details_binding.dart';
import '../modules/cafeteria_meal_details/views/cafeteria_meal_details_view.dart';
import '../modules/cafeteria_menu_page/bindings/cafeteria_menu_page_binding.dart';
import '../modules/cafeteria_menu_page/views/cafeteria_menu_page_view.dart';
import '../modules/cafeteria_phone_authenication/bindings/cafeteria_phone_authenication_binding.dart';
import '../modules/cafeteria_phone_authenication/views/cafeteria_phone_authenication_view.dart';
import '../modules/cafeteria_phone_verification/bindings/cafeteria_phone_verification_binding.dart';
import '../modules/cafeteria_phone_verification/views/cafeteria_phone_verification_view.dart';
import '../modules/cafeteria_setting_history/bindings/cafeteria_setting_history_binding.dart';
import '../modules/cafeteria_setting_history/views/cafeteria_setting_history_view.dart';
import '../modules/cafeteria_settings/bindings/cafeteria_settings_binding.dart';
import '../modules/cafeteria_settings/views/cafeteria_settings_view.dart';
import '../modules/cafeteria_staff_list/bindings/cafeteria_staff_list_binding.dart';
import '../modules/cafeteria_staff_list/views/cafeteria_staff_list_view.dart';
import '../modules/cafeteria_upcoming_detail/binding/cafeteria_upcoming_detail_binding.dart';
import '../modules/cafeteria_upcoming_detail/view/cafeteria_upcoming_detail_viewe.dart';
import '../modules/child_verification_upload_info/bindings/child_verification_upload_info_binding.dart';
import '../modules/child_verification_upload_info/views/child_verification_upload_info_view.dart';
import '../modules/children_details/bindings/children_details_binding.dart';
import '../modules/children_details/views/children_details_view.dart';
import '../modules/email_verification/bindings/email_verification_binding.dart';
import '../modules/email_verification/views/email_verification_view.dart';
import '../modules/forget_password/bindings/forget_password_binding.dart';
import '../modules/forget_password/views/forget_password_view.dart';
import '../modules/home_settings/bindings/home_settings_binding.dart';
import '../modules/home_settings/views/home_settings_view.dart';
import '../modules/landing_page/bindings/landing_page_binding.dart';
import '../modules/landing_page/views/landing_page_view.dart';
import '../modules/menu_page/bindings/menu_page_binding.dart';
import '../modules/menu_page/views/menu_page_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/parent_children_edit/binding/parent_children_edit_binding.dart';
import '../modules/parent_children_edit/view/parent_children_edit_VIEW.dart';
import '../modules/parent_name/bindings/parent_name_binding.dart';
import '../modules/parent_name/views/parent_name_view.dart';
import '../modules/parent_upcoming_order_detail/binding/parent_upcoming_order_detail_binding.dart';
import '../modules/parent_upcoming_order_detail/view/parent_upcoming_order_detail_view.dart';
import '../modules/parents_add_wallet/bindings/parents_add_wallet_binding.dart';
import '../modules/parents_add_wallet/views/parents_add_wallet_view.dart';
import '../modules/parents_children_details/bindings/parents_children_details_binding.dart';
import '../modules/parents_children_details/views/parents_children_details_view.dart';
import '../modules/parents_history/bindings/parents_history_binding.dart';
import '../modules/parents_history/views/parents_history_view.dart';
import '../modules/parents_history_details/bindings/parents_history_details_binding.dart';
import '../modules/parents_history_details/views/parents_history_details_view.dart';
import '../modules/parents_history_list/bindings/parents_history_list_binding.dart';
import '../modules/parents_history_list/views/parents_history_list_view.dart';
import '../modules/parents_history_select_date/bindings/parents_history_select_date_binding.dart';
import '../modules/parents_history_select_date/views/parents_history_select_date_view.dart';
import '../modules/parents_home/bindings/parents_home_binding.dart';
import '../modules/parents_home/views/parents_home_view.dart';
import '../modules/parents_orders_history/bindings/parents_orders_history_binding.dart';
import '../modules/parents_orders_history/views/parents_orders_history_view.dart';
import '../modules/parents_profile/binding/parent_profile_binding.dart';
import '../modules/parents_profile/view/parent_profile_view.dart';
import '../modules/phone_authentication/bindings/phone_authentication_binding.dart';
import '../modules/phone_authentication/views/phone_authentication_view.dart';
import '../modules/phone_verification/bindings/phone_verification_binding.dart';
import '../modules/phone_verification/views/phone_verification_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/qr_code/bindings/qr_code_binding.dart';
import '../modules/qr_code/views/qr_code_view.dart';
import '../modules/selection/bindings/selection_binding.dart';
import '../modules/selection/views/selection_view.dart';
import '../modules/setting_parent_profile/bindings/setting_parent_profile_binding.dart';
import '../modules/setting_parent_profile/views/setting_parent_profile_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/sign_in/bindings/sign_in_binding.dart';
import '../modules/sign_in/views/sign_in_view.dart';
import '../modules/sign_up/bindings/sign_up_binding.dart';
import '../modules/sign_up/views/sign_up_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/staff_child_verification/bindings/staff_child_verification_binding.dart';
import '../modules/staff_child_verification/views/staff_child_verification_view.dart';
import '../modules/staff_delivered_order_history_detail/binding/binding.dart';
import '../modules/staff_delivered_order_history_detail/bindings/staff_delivered_order_history_detail_binding.dart';
import '../modules/staff_delivered_order_history_detail/view/staff_delivered_order_history_detail_view.dart';
import '../modules/staff_history/bindings/staff_history_binding.dart';
import '../modules/staff_history/views/staff_history_view.dart';
import '../modules/staff_history_calender/bindings/staff_history_calender_binding.dart';
import '../modules/staff_history_calender/views/staff_history_calender_view.dart';
import '../modules/staff_history_detail/bindings/staff_history_detail_binding.dart';
import '../modules/staff_history_detail/views/staff_history_detail_view.dart';
import '../modules/staff_history_list/bindings/staff_history_list_binding.dart';
import '../modules/staff_history_list/views/staff_history_list_view.dart';
import '../modules/staff_home_settings/bindings/staff_home_settings_binding.dart';
import '../modules/staff_home_settings/views/staff_home_settings_view.dart';
import '../modules/staff_landing_page/bindings/staff_landing_page_binding.dart';
import '../modules/staff_landing_page/views/staff_landing_page_view.dart';
import '../modules/staff_meal_selection/bindings/staff_meal_selection_binding.dart';
import '../modules/staff_meal_selection/views/staff_meal_selection_view.dart';
import '../modules/staff_order_details/bindings/staff_order_details_binding.dart';
import '../modules/staff_order_details/views/staff_order_details_view.dart';
import '../modules/staff_order_history/bindings/staff_order_history_binding.dart';
import '../modules/staff_order_history/views/staff_order_history_view.dart';
import '../modules/staff_phone_verification/bindings/staff_phone_verification_binding.dart';
import '../modules/staff_phone_verification/views/staff_phone_verification_view.dart';
import '../modules/staff_preparing/bindings/staff_preparing_binding.dart';
import '../modules/staff_preparing/views/staff_preparing_view.dart';
import '../modules/staff_profile/bindings/staff_profile_binding.dart';
import '../modules/staff_profile/views/staff_profile_view.dart';
import '../modules/staff_setting_profile/bindings/staff_setting_profile_binding.dart';
import '../modules/staff_setting_profile/views/staff_setting_profile_view.dart';
import '../modules/staff_settings/bindings/staff_settings_binding.dart';
import '../modules/staff_settings/views/staff_settings_view.dart';
import '../modules/stripe_onboarding/view/stripe_onboarding_view.dart';
import '../modules/cafe_owner_order_delivery_details/bindings/cafe_owner_order_delivery_details_binding.dart';
import '../modules/cafe_owner_order_delivery_details/views/cafe_owner_order_delivery_details_view.dart';
import '../modules/parent_order_delivery_details/bindings/parent_order_delivery_details_binding.dart';
import '../modules/parent_order_delivery_details/views/parent_order_delivery_details_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_IN,
      page: () => const SignInView(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: _Paths.FORGET_PASSWORD,
      page: () => const ForgetPasswordView(),
      binding: ForgetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.SELECTION,
      page: () => const SelectionView(),
      binding: SelectionBinding(),
    ),
    GetPage(
      name: _Paths.EMAIL_VERIFICATION,
      page: () => const EmailVerificationView(),
      binding: EmailVerificationBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA,
      page: () => CafeteriaView(),
      binding: CafeteriaBinding(),
    ),
    GetPage(
      name: _Paths.CHILDREN_DETAILS,
      page: () => const ChildrenDetailsView(),
      binding: ChildrenDetailsBinding(),
    ),
    GetPage(
      name: _Paths.MENU_PAGE,
      page: () => MenuPageView(),
      binding: MenuPageBinding(),
    ),
    GetPage(
      name: _Paths.QR_CODE,
      page: () => const QrCodeView(),
      binding: QrCodeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.PARENTS_HOME,
      page: () => const ParentsHomeView(),
      binding: ParentsHomeBinding(),
    ),
    GetPage(
      name: _Paths.PARENTS_HISTORY,
      page: () => const ParentsHistoryView(),
      binding: ParentsHistoryBinding(),
    ),
    GetPage(
      name: _Paths.PARENTS_HISTORY_LIST,
      page: () => const ParentsHistoryListView(),
      binding: ParentsHistoryListBinding(),
    ),
    GetPage(
      name: _Paths.PARENTS_HISTORY_SELECT_DATE,
      page: () => const ParentsHistorySelectDateView(),
      binding: ParentsHistorySelectDateBinding(),
    ),
    GetPage(
      name: _Paths.PARENTS_HISTORY_DETAILS,
      page: () => const ParentsHistoryDetailsView(),
      binding: ParentsHistoryDetailsBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_MEAL_DETAILS,
      page: () => const CafeteriaMealDetailsView(),
      binding: CafeteriaMealDetailsBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_MENU_PAGE,
      page: () => const CafeteriaMenuPageView(),
      binding: CafeteriaMenuPageBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_HISTORY,
      page: () => const CafeteriaHistoryView(),
      binding: CafeteriaHistoryBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_HISTORY_LIST,
      page: () => const CafeteriaHistoryListView(),
      binding: CafeteriaHistoryListBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_HISTORY_SELECT_DATE,
      page: () => const CafeteriaHistorySelectDateView(),
      binding: CafeteriaHistorySelectDateBinding(),
    ),
    GetPage(
      name: _Paths.PHONE_AUTHENTICATION,
      page: () => const PhoneAuthenticationView(),
      binding: PhoneAuthenticationBinding(),
    ),
    GetPage(
      name: _Paths.PHONE_VERIFICATION,
      page: () => const PhoneVerificationView(),
      binding: PhoneVerificationBinding(),
    ),
    GetPage(
      name: _Paths.LANDING_PAGE,
      page: () => const LandingPageView(),
      binding: LandingPageBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_DETAIL,
      page: () => const CafeteriaDetailView(),
      binding: CafeteriaDetailBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_LANDING_PAGE,
      page: () => const CafeteriaLandingPageView(),
      binding: CafeteriaLandingPageBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_CHILD_VERIFICATION,
      page: () => const CafeteriaChildVerificationView(),
      binding: CafeteriaChildVerificationBinding(),
    ),
    GetPage(
      name: _Paths.PARENTS_CHILDREN_DETAILS,
      page: () => const ParentsChildrenDetailsView(),
      binding: ParentsChildrenDetailsBinding(),
    ),
    GetPage(
      name: _Paths.PARENTS_CHILDREN_EDIT,
      page: () => const ParentsChildrenEditView(),
      binding: ParentsChildrenEditBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_PHONE_AUTHENICATION,
      page: () => const CafeteriaPhoneAuthenicationView(),
      binding: CafeteriaPhoneAuthenicationBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_PHONE_VERIFICATION,
      page: () => const CafeteriaPhoneVerificationView(),
      binding: CafeteriaPhoneVerificationBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_HISTORY_DETAILS,
      page: () => const CafeteriaHistoryDetailsView(),
      binding: CafeteriaHistoryDetailsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.PARENT_NAME,
      page: () => const ParentNameView(),
      binding: ParentNameBinding(),
    ),
    GetPage(
      name: Routes.CHILD_VERIFICATION_UPLOAD_INFO,
      page: () => const ChildVerificationUploadInfoView(),
      binding: ChildVerificationUploadInfoBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_CHILD_VERIFICATION_HOME,
      page: () => const CafeteriaChildVerificationHomeView(),
      binding: CafeteriaChildVerificationHomeBinding(),
    ),
    GetPage(
      name: _Paths.HOME_SETTINGS,
      page: () => const HomeSettingsView(),
      binding: HomeSettingsBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_PHONE_VERIFICATION,
      page: () => StaffPhoneAuthenticationView(),
      binding: StaffPhoneVerificationBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_MEAL_SELECTION,
      page: () => const StaffMealSelectionView(),
      binding: StaffMealSelectionBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_PREPARING,
      page: () => const StaffPreparingView(),
      binding: StaffPreparingBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_HISTORY,
      page: () => const StaffHistoryView(),
      binding: StaffHistoryBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.STAFF_DELIVERED_ORDER_HISTORY_DETAILS,
      page: () => const StaffDeliveredOrderHistoryDetails(),
      binding: StaffDeliveredOrderHistoryDetailBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.STAFF_HISTORY_CALENDER,
      page: () => const StaffHistoryCalenderView(),
      binding: StaffHistoryCalenderBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_HISTORY_DETAIL,
      page: () => const StaffHistoryDetailView(),
      binding: StaffHistoryDetailBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_UPCOMING_DETAIL,
      page: () => const CafeteriaUpcomingDetailsView(),
      binding: CafeteriaUpcomingDetailsBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_CHILD_VERIFICATION,
      page: () => const StaffChildVerificationView(),
      binding: StaffChildVerificationBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_LANDING_PAGE,
      page: () => const StaffLandingPageView(),
      binding: StaffLandingPageBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_HISTORY_LIST,
      page: () => const StaffHistoryListView(),
      binding: StaffHistoryListBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_SETTINGS,
      page: () => const StaffSettingsView(),
      binding: StaffSettingsBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_HOME_SETTINGS,
      page: () => const StaffHomeSettingsView(),
      binding: StaffHomeSettingsBinding(),
    ),
    GetPage(
      name: _Paths.STAFF_PROFILE,
      page: () => const StaffProfileView(),
      binding: StaffProfileBinding(),
    ),
    GetPage(
      name: _Paths.PARENT_PROFILE,
      page: () => const ParentsProfileView(),
      binding: ParentsProfileBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_ADD_STAFF,
      page: () => const CafeteriaAddStaffView(),
      binding: CafeteriaAddStaffBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_EDIT_STAFF,
      page: () => CafeteriaEditStaffView(),
      binding: CafeteriaEditStaffBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_STAFF_LIST,
      page: () => const CafeteriaStaffListView(),
      binding: CafeteriaStaffListBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_HOME_SETTINGS,
      page: () => const CafeteriaHomeSettingsView(),
      binding: CafeteriaHomeSettingsBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_SETTINGS,
      page: () => const CafeteriaSettingsView(),
      binding: CafeteriaSettingsBinding(),
    ),
    GetPage(
      name: _Paths.PARENTS_ADD_WALLET,
      page: () => const ParentsAddWalletView(),
      binding: ParentsAddWalletBinding(),
    ),
    GetPage(
      name: _Paths.CAFETERIA_SETTING_HISTORY,
      page: () => const CafeteriaSettingHistoryView(),
      binding: CafeteriaSettingHistoryBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: Routes.PARENT_UPCOMING_ORDER_DETAIL,
      page: () => const ParentUpcomingOrderDetailView(),
      binding: ParentUpcomingOrderDetailBinding(),
    ),
    GetPage(
      name: Routes.SETTING_PARENT_PROFILE,
      page: () => const SettingParentProfileView(),
      binding: SettingParentProfileBinding(),
    ),
    GetPage(
      name: Routes.ADMIN_SETTING_PROFILE,
      page: () => const AdminSettingProfileView(),
      binding: AdminSettingProfileBinding(),
    ),
    GetPage(
      name: Routes.STAFF_SETTING_PROFILE,
      page: () => const StaffSettingProfileView(),
      binding: StaffSettingProfileBinding(),
    ),
    GetPage(
      name: _Paths.STRIPE_ONBOARDING,
      page: () {
        // Check if arguments and url are provided
        final args = Get.arguments;
        if (args == null || args['url'] == null) {
          // Show error and return to previous screen
          Future.microtask(() {
            Get.back();
            Get.snackbar(
              'Error',
              'Missing Stripe onboarding URL. Please try again.',
              backgroundColor: Colors.red[100],
              colorText: Colors.red[800],
            );
          });
          // Return a placeholder widget while we're navigating back
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If URL is provided, return the StripeOnboardingView
        return StripeOnboardingView(
          url: args['url'],
        );
      },
    ),
    GetPage(
      name: _Paths.STAFF_ORDER_HISTORY,
      page: () => const StaffOrderHistoryView(),
      binding: StaffOrderHistoryBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.STAFF_ORDER_DETAILS,
      page: () => const StaffOrderDetailsView(),
      binding: StaffOrderDetailsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.PARENTS_ORDERS_HISTORY,
      page: () => const ParentsOrdersHistoryView(),
      binding: ParentsOrdersHistoryBinding(),
    ),
    GetPage(
      name: _Paths.CAFE_OWNER_ORDER_DELIVERY_DETAILS,
      page: () => const CafeOwnerOrderDeliveryDetailsView(),
      binding: CafeOwnerOrderDeliveryDetailsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.PARENT_ORDER_DELIVERY_DETAILS,
      page: () => const ParentOrderDeliveryDetailsView(),
      binding: ParentOrderDeliveryDetailsBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
