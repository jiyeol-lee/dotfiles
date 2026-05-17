# Complex Variant Snapshot Example

User request: "Draw an ASCII layout for an account dashboard where role permissions and data availability change multiple visible regions. Use React/TypeScript pseudocode."

## ASCII Layout

Variant: manager with account data

```
+--------------------------------------------------------+
| 1] 1>                                                  |
| +------------+ +-------------------------------------+ |
| | 2]         | | 3]                                  | |
| |            | +-------------------------------------+ |
| |            | +-----------------+ +-----------------+ |
| |            | | 4]              | | 5]              | |
| |            | +-----------------+ +-----------------+ |
| |            | +-------------------------------------+ |
| |            | | 6]                                  | |
| |            | +-------------------------------------+ |
| |            | +-------------------------------------+ |
| |            | | 7]                                  | |
| +------------+ +-------------------------------------+ |
| +----------------------------------------------------+ |
| | 8]                                                 | |
| +----------------------------------------------------+ |
+--------------------------------------------------------+
```

Variant: viewer with no account data

```
+--------------------------------------------------------+
| 1] 1>                                                  |
| +------------+ +-------------------------------------+ |
| | 2]         | | 3]                                  | |
| |            | +-------------------------------------+ |
| |            | +-----------------+ +-----------------+ |
| |            | | 9]              | | 10]             | |
| |            | +-----------------+ +-----------------+ |
| |            | +-------------------------------------+ |
| |            | | 11]                                 | |
| |            | +-------------------------------------+ |
| +------------+ +-------------------------------------+ |
| +----------------------------------------------------+ |
| | 8]                                                 | |
| +----------------------------------------------------+ |
+--------------------------------------------------------+
```

## Condition Plan

- 1? condition: dashboard role and data availability
  source: Current user's account role plus account overview query result.
  variants: Manager users with account data see action controls `4]`, performance chart `5]`, recent activity `6]`, and team management panel `7]`; viewer users with no account data see limited summary `9]`, empty chart guidance `10]`, and empty activity state `11]`.
  details: Shared shell, navigation, header, and footer keep labels `1]`, `2]`, `3]`, and `8]` across both snapshots. Conditional components use distinct labels because they render different visible UI, even where `4]` and `9]`, `5]` and `10]`, or `6]` and `11]` occupy the same slots.

## Component Plan

- 1] component: AccountDashboardPage
  update: `src/features/account/AccountDashboardPage.tsx`
  details: Owns the account dashboard layout, loads account overview data, reads the current user's role, and selects the manager-data or viewer-empty visible regions. It passes shared account data to the sidebar, header, and footer while passing role and data-state-specific props to conditional dashboard regions.
  \_pseudocode:

  ```tsx
  const account = useAccountOverview();
  const role = useAccountRole();
  const hasData = account.data.metrics.length > 0;

  return role.canManage && hasData ? (
    <ManagerDashboard />
  ) : (
    <ViewerEmptyDashboard />
  );
  ```

- 2] component: AccountSidebar
  reuse: `src/features/account/components/AccountSidebar.tsx`
  details: Provides account navigation and already accepts the active route and account id through existing props. It appears unchanged in both variants and requires no code changes.

- 3] component: DashboardHeader
  update: `src/features/account/components/DashboardHeader.tsx`
  details: Shows account name, date range, and primary actions. It remains visually shared in both variants but receives role capability and data availability props so the visible action copy can stay aligned with the selected snapshot.
  \_pseudocode:

  ```tsx
  export function DashboardHeader({ account, canManage, hasData }: Props) {
    return (
      <header>
        {canManage && hasData ? "Manage account" : "View account"}
      </header>
    );
  }
  ```

- 4] component: ManagerActionCards
  create: `src/features/account/components/ManagerActionCards.tsx`
  details: Shows manager-only action cards when the user has management permission and account data exists. It receives account id, task counts, and action handlers from `AccountDashboardPage`.
  \_pseudocode:

  ```tsx
  export function ManagerActionCards({ accountId, tasks }: Props) {
    return <section>{tasks.map(renderTask)}</section>;
  }
  ```

- 5] component: PerformanceChart
  create: `src/features/account/components/PerformanceChart.tsx`
  details: Shows account performance metrics when data is available. It receives normalized chart series from `AccountDashboardPage` and supports dynamic date range changes from the existing dashboard controls.
  \_pseudocode:

  ```tsx
  export function PerformanceChart({ series }: Props) {
    return <LineChart data={series} />;
  }
  ```

- 6] component: RecentActivityList
  reuse: `src/features/account/components/RecentActivityList.tsx`
  details: Shared activity feed implementation used when account activity exists. It receives activity items from the existing query and keeps its current props, pagination, and empty handling unchanged.

- 7] component: TeamManagementPanel
  create: `src/features/account/components/TeamManagementPanel.tsx`
  details: Manager-only panel for inviting teammates and changing roles. It receives account id and permission data from `AccountDashboardPage` and emits existing analytics events when actions are selected.
  \_pseudocode:

  ```tsx
  export function TeamManagementPanel({ accountId, permissions }: Props) {
    return <aside>{permissions.canInvite ? <InviteButton /> : null}</aside>;
  }
  ```

- 8] component: DashboardFooter
  reuse: `src/features/account/components/DashboardFooter.tsx`
  details: Shared footer with support links and legal copy. It is static across both variants and does not need data, props, state, or behavior changes.

- 9] component: ViewerSummaryBanner
  create: `src/features/account/components/ViewerSummaryBanner.tsx`
  details: Viewer-facing summary shown when account data is unavailable or the user lacks management permission. It receives account name and support links from the page and avoids showing manager-only controls.
  \_pseudocode:

  ```tsx
  export function ViewerSummaryBanner({ accountName }: Props) {
    return <section>{accountName}</section>;
  }
  ```

- 10] component: EmptyChartGuidance
  create: `src/features/account/components/EmptyChartGuidance.tsx`
  details: Explains why performance data is not visible and links to setup documentation. The message is selected from account data availability and role capability passed by `AccountDashboardPage`.
  \_pseudocode:

  ```tsx
  export function EmptyChartGuidance({ reason }: Props) {
    return <section>{reason}</section>;
  }
  ```

- 11] component: EmptyActivityState
  create: `src/features/account/components/EmptyActivityState.tsx`
  details: Replaces the activity list when there are no activity items. It receives a support URL and optional setup action from the page and does not own asynchronous state.
  \_pseudocode:

  ```tsx
  export function EmptyActivityState({ supportUrl }: Props) {
    return <a href={supportUrl}>Learn more</a>;
  }
  ```

## State Plan

- 1> state: dashboard role and data state
  update: `src/features/account/AccountDashboardPage.tsx`
  details: Owned by `AccountDashboardPage` and consumed by `DashboardHeader` plus the conditional dashboard region selection. Initial values come from the account overview query and current session role; updates occur when the query refreshes or the signed-in user's permissions change.
  \_pseudocode:

  ```tsx
  const role = useAccountRole();
  const hasData = account.data.metrics.length > 0;
  const variant = role.canManage && hasData ? "manager-data" : "viewer-empty";
  ```

## Final Folder Structure

```text
src/
+-- features/
    +-- account/
        +-- AccountDashboardPage.tsx [update]
        +-- components/
            +-- AccountSidebar.tsx [reuse]
            +-- DashboardHeader.tsx [update]
            +-- ManagerActionCards.tsx [create]
            +-- PerformanceChart.tsx [create]
            +-- RecentActivityList.tsx [reuse]
            +-- TeamManagementPanel.tsx [create]
            +-- DashboardFooter.tsx [reuse]
            +-- ViewerSummaryBanner.tsx [create]
            +-- EmptyChartGuidance.tsx [create]
            +-- EmptyActivityState.tsx [create]
```
