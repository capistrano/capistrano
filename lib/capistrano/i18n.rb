require 'i18n'
en = {
  starting: 'Starting',
  capified: 'Capified',
  starting: 'Starting',
  start: 'Start',
  update: 'Update',
  finalize: 'Finalise',
  restart: 'Restart',
  finishing: 'Finishing',
  finished: 'Finished',
  stage_not_set: 'Stage not set',
  written_file: 'create %{file}',
  question: 'Please enter %{key}: |%{default_value}|',
  keeping_releases: 'Keeping %{keep_releases} of %{releases} deployed releases',
  linked_file_does_not_exist: 'linked file %{file} does not exist on %{host}',
  mirror_exists: "The repository mirror is at %{at}",
  revision_log_message: 'Branch %{branch} deployed as release %{release} by %{user}',
  rollback_log_message: '%{user} rolled back to release %{release}',
  console: {
    welcome: 'capistrano console - enter command to execute on %{stage}',
    bye: 'bye'
  },
  error: {
    user: {
      does_not_exist: 'User %{user} does not exists',
      cannot_switch: 'Cannot switch to user %{user}'
    }
  }
}
I18n.backend.store_translations(:en, { capistrano: en })
