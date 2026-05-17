# Intermediate ASCII Layout Example

User request: "Draw an ASCII layout for a settings page with a sidebar, profile form, compact role controls, and save bar. Use React/TypeScript pseudocode."

## ASCII Layout

Main layout

```
+-----------------------------------------------+
| +-----------+ +-----------------------------+ |
| | 1]        | | 2] 1>                       | |
| |           | +-----------------------------+ |
| |           | +-----------------------------+ |
| |           | | 3]                          | |
| +-----------+ +-----------------------------+ |
+-----------------------------------------------+
```

## Magnified Views

Magnified view for 2]

```
+-----------------------------------------+
| 2] 1>                                   |
| +-------------------------------------+ |
| | 2-1]                                | |
| +-------------------------------------+ |
| +--------------+ +--------------------+ |
| | 2-2] 1>      | | 2-3]               | |
| +--------------+ +--------------------+ |
+-----------------------------------------+
```

## Component Plan

- 1] component: SettingsSidebar
  reuse: `src/components/settings/SettingsSidebar.tsx`
  details: Provides navigation for settings sections. It already supports route-aware active state and accepts the existing settings navigation configuration, so no data loading, prop, styling, or behavior changes are required.

- 2] component: ProfileSettingsForm
  update: `src/features/settings/ProfileSettingsForm.tsx`
  details: Owns the editable profile form region and coordinates child controls. User settings come from the existing settings query; local form state tracks dirty fields and validation; it passes role options, field values, and change handlers to nested controls.
  \_pseudocode:

  ```tsx
  const settings = useUserSettings();
  const form = useSettingsForm(settings.data);

  return <ProfileForm value={form.value} onChange={form.setField} />;
  ```

- 2-1] component: SettingsFormHeader
  create: `src/features/settings/components/SettingsFormHeader.tsx`
  details: Displays the form title, helper copy, and optional loading indicator from the parent form. It receives `title`, `description`, and `isLoading` props and does not fetch data or own state.
  \_pseudocode:

  ```tsx
  type Props = { title: string; description: string; isLoading?: boolean };

  export function SettingsFormHeader(props: Props) {
    return <header aria-busy={props.isLoading}>{props.title}</header>;
  }
  ```

- 2-2] component: RoleDropdown
  reuse: `src/components/forms/Dropdown.tsx`
  details: Reuses the existing controlled dropdown for role selection. Options are static for this page: `Admin`, `Editor`, and `Viewer`; the parent supplies `options`, `value`, and `onChange` through existing props, with no dropdown implementation changes.

- 2-3] component: NotificationToggleGroup
  update: `src/features/settings/ProfileSettingsForm.tsx`
  details: Adds controlled notification toggles inside the profile form. Initial values come from user settings, updates write to local form state, and accessible labels describe email and product notification choices.
  \_pseudocode:

  ```tsx
  <Toggle
    checked={form.value.emailNotifications}
    onChange={(value) => form.setField("emailNotifications", value)}
  />
  ```

- 3] component: SettingsSaveBar
  create: `src/features/settings/components/SettingsSaveBar.tsx`
  details: Shows reset and save actions when the profile form is dirty. It receives `isDirty`, `isSaving`, `onReset`, and `onSave` props from `ProfileSettingsForm` and does not own persistence logic.
  \_pseudocode:

  ```tsx
  export function SettingsSaveBar(props: Props) {
    if (!props.isDirty) return null;
    return (
      <footer>
        <button onClick={props.onSave}>Save</button>
      </footer>
    );
  }
  ```

## State Plan

- 1> state: profile settings form state
  update: `src/features/settings/ProfileSettingsForm.tsx`
  details: Owned by `ProfileSettingsForm` and consumed by validation, `RoleDropdown`, `NotificationToggleGroup`, dirty-state detection, reset behavior, and save payload creation. Initial values come from the current user settings query; field changes trigger updates; role options are static while field values are dynamic per user.
  \_pseudocode:

  ```tsx
  const form = useSettingsForm(settings.data, {
    roleOptions: ["Admin", "Editor", "Viewer"],
  });
  ```

## Final Folder Structure

```text
src/
+-- components/
|   +-- forms/
|   |   +-- Dropdown.tsx [reuse]
|   +-- settings/
|       +-- SettingsSidebar.tsx [reuse]
+-- features/
    +-- settings/
        +-- ProfileSettingsForm.tsx [update]
        +-- components/
            +-- SettingsFormHeader.tsx [create]
            +-- SettingsSaveBar.tsx [create]
```
