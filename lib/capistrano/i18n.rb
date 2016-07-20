require "i18n"

en = {
  starting: "Starting",
  capified: "Capified",
  start: "Start",
  update: "Update",
  finalize: "Finalise",
  finishing: "Finishing",
  finished: "Finished",
  stage_not_set: "Stage not set, please call something such as `cap production deploy`, where production is a stage you have defined.",
  written_file: "create %{file}",
  question: "Please enter %{key} (%{default_value}): ",
  keeping_releases: "Keeping %{keep_releases} of %{releases} deployed releases on %{host}",
  no_old_releases: "No old releases (keeping newest %{keep_releases}) on %{host}",
  linked_file_does_not_exist: "linked file %{file} does not exist on %{host}",
  cannot_rollback: "There are no older releases to rollback to",
  cannot_found_rollback_release: "Cannot rollback because release %{release} does not exist",
  mirror_exists: "The repository mirror is at %{at}",
  revision_log_message: "Branch %{branch} (at %{sha}) deployed as release %{release} by %{user}",
  rollback_log_message: "%{user} rolled back to release %{release}",
  deploy_failed: "The deploy has failed with an error: %{ex}",
  console: {
    welcome: "capistrano console - enter command to execute on %{stage}",
    bye: "bye"
  },
  error: {
    invalid_stage_name: '"%{name}" is a reserved word and cannot be used as a stage. Rename "%{path}" to something else.',
    user: {
      does_not_exist: "User %{user} does not exists",
      cannot_switch: "Cannot switch to user %{user}"
    }
  }
}

I18n.backend.store_translations(:en, capistrano: en)

if I18n.respond_to?(:enforce_available_locales=)
  I18n.enforce_available_locales = true
end
