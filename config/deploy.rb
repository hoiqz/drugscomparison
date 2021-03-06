require "rvm/capistrano"

set :user, 'hoi'
set :domain, '54.235.209.29'
set :application, 'drugscomparison'
#set :rake, 'bundle exec rake'
# file paths
set :repository,  "#{user}@#{domain}:~/git/#{application}.git"
#set :repository, "git@github.com:hoiqz/drugscomparison.git"
#set :repository,  "RemoteServer:/~/git/#{application}.git"
#set :scm_passphrase, "h0160Biopolis"
set :deploy_to, "/home/#{user}/#{application}_deployed"
set :ssh_options, {:forward_agent => true}
#set :scm_username, 'hoi'
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_dsa")]
set :use_sudo, false

# distribute your applications across servers (the instructions below put them
# all on the same server, defined above as 'domain', adjust as necessary)
role :app, domain
role :web, domain
role :db, domain, :primary => true

# you might need to set this if you aren't seeing password prompts
default_run_options[:pty] = true

# As Capistrano executes in a non-interactive mode and therefore doesn't cause
# any of your shell profile scripts to be run, the following might be needed
# if (for example) you have locally installed gems or applications.  Note:
# this needs to contain the full values for the variables set, not simply
# the deltas.
# default_environment['PATH']='<your paths>:/usr/local/bin:/usr/bin:/bin'
# default_environment['GEM_PATH']='<your paths>:/usr/lib/ruby/gems/1.8'

# miscellaneous options
set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false

namespace :deploy do
  desc "cause Passenger to initiate a restart"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=production"
  end

  desc "install the necessary prerequisites"
  task :bundle_install, :roles => :app do
    run "cd #{release_path} && bundle install"
  end

  desc "create directory for solr data"
  task :setup_solr_data_dir do
    run "mkdir -p #{shared_path}/solr/data"
  end

  #desc "generate commondrugs"
  #task :run_specific_rake_tasks do
  #  run "cd #{deploy_to}/current && #{rake} project:generateCommondrugContent RAILS_ENV=production"
  #end
end

## solr cap deploy
namespace :solr do
  desc "start solr"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec sunspot-solr start --port=8983 --data-directory=#{shared_path}/solr/data --pid-dir=#{shared_path}/pids"
  end
  desc "stop solr"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec sunspot-solr stop --port=8983 --data-directory=#{shared_path}/solr/data --pid-dir=#{shared_path}/pids"
  end
  desc "reindex the whole database"
  task :reindex, :roles => :app do
    stop
    run "rm -rf #{shared_path}/solr/data"
    start
    run "cd #{current_path} && RAILS_ENV=#{rails_env} && yes | bundle exec rake sunspot:solr:reindex"
  end
end

after "deploy:update_code", "deploy:bundle_install",'deploy:setup_solr_data_dir'
#after 'deploy:setup',
