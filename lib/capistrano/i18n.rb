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
  written_stage_file: 'create config/deploy/%{stage}.rb',
  error: {
    user: {
      does_not_exist: 'User %{user} does not exists',
      cannot_switch: 'Cannot switch to user %{user}'
    }
  }
}
I18n.backend.store_translations(:en, { capistrano: en })
