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
  stage_not_set: 'Stage not set'
}
I18n.backend.store_translations(:en, { capistrano: en })
