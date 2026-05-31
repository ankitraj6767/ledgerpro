class AppConstants {
  const AppConstants._();

  // Configurable app identity (Phase: keep name configurable).
  static const appName = 'Navdream Infra Pvt. Ltd.';
  static const appTagline = 'We Build Today, For a Better Tomorrow';
  static const currency = 'INR';
  static const defaultLocale = 'en_IN';
  static const supportEmail = 'support@navdreaminfra.com';
}

class AppRoutes {
  const AppRoutes._();

  // Auth + shell
  static const splash = '/splash';
  static const login = '/login';
  static const otp = '/otp';
  static const appLock = '/app-lock';
  static const unlock = '/unlock';
  static const onboarding = '/onboarding';

  // Bottom nav
  static const home = '/home';
  static const projects = '/projects';
  static const expenses = '/expenses';
  static const reports = '/reports';
  static const profile = '/profile';

  // Projects
  static const newProject = '/projects/new';
  static String projectDetail(String id) => '/projects/$id';
  static String editProject(String id) => '/projects/$id/edit';
  static String projectInvestors(String id) => '/projects/$id/investors';
  static String newInvestment(String id) => '/projects/$id/investments/new';
  static String projectGovtFunds(String id) => '/projects/$id/government-funds';
  static String newGovtFund(String id) => '/projects/$id/government-funds/new';
  static String newGovtReceipt(String id) =>
      '/projects/$id/government-receipts/new';
  static String projectExpenses(String id) => '/projects/$id/expenses';
  static String newExpense(String id) => '/projects/$id/expenses/new';
  static String projectDocuments(String id) => '/projects/$id/documents';
  static String projectNotes(String id) => '/projects/$id/notes';
  static String projectReports(String id) => '/projects/$id/reports';

  // Path templates for GoRouter definitions.
  static const projectDetailPath = '/projects/:projectId';
  static const editProjectPath = '/projects/:projectId/edit';
  static const projectInvestorsPath = '/projects/:projectId/investors';
  static const newInvestmentPath = '/projects/:projectId/investments/new';
  static const projectGovtFundsPath = '/projects/:projectId/government-funds';
  static const newGovtFundPath = '/projects/:projectId/government-funds/new';
  static const newGovtReceiptPath =
      '/projects/:projectId/government-receipts/new';
  static const projectExpensesPath = '/projects/:projectId/expenses';
  static const newExpensePath = '/projects/:projectId/expenses/new';
  static const projectDocumentsPath = '/projects/:projectId/documents';
  static const projectNotesPath = '/projects/:projectId/notes';
  static const projectReportsPath = '/projects/:projectId/reports';

  // Other
  static const staff = '/staff';
  static const auditLogs = '/audit-logs';
  static const settings = '/settings';
  static const customers = '/settings/customers';
  static const syncQueue = '/sync-queue';
  static const newInvestor = '/investors/new';
}
