require 'ftools'
require 'fileutils'
require 'heroku/commands/auth'

module Heroku::Command
  class Accounts < BaseWithApp
    CURRENT_DIR = 'current_account'
    HEROKU_DIR = '.heroku'

    def index
      setup

      Dir[File.join(accounts_path, '*')].each do |path|
        display File.basename(path)
      end
    end

    def add
      if account = args.first
        unless File.directory?(account_path(account))
          display "Creating account #{account}"

          account_path = account_path(account)
          FileUtils.mkdir_p(account_path)

          ssh_key = File.join(account_path, 'id_rsa')
          `ssh-keygen -f #{ssh_key} -N '' > /dev/null`

          Class.new(Heroku::Command::Auth).tap do |auth|
            auth.class_eval <<-end_eval
              def credentials_file
                "#{File.join(account_path, 'credentials')}"
              end
            end_eval

            auth.new(["#{ssh_key}.pub"]).get_credentials
          end

          Heroku::Command.run_internal('accounts:switch', [account])
        end
      else
        display "Usage: heroku accounts:add account_name"
      end
    end

    def switch
      if account = args.first
        if account?(account)
          Dir.chdir(heroku_path)
          FileUtils.rm(CURRENT_DIR)
          File.symlink(File.join('accounts', account), CURRENT_DIR)
          display "Switched to #{account}"
        end
      else
        display "Usage: heroku switch account_name"
      end
    end

    def remove
      if account?(args.first)
        FileUtils.rm_rf(account_path(args.first), :secure => true)
      else
        display "Usage: heroku accounts:remove account_name"
      end
    end

    def setup
      unless File.directory?(accounts_path)
        if account = args.first
          display "Creating initial account #{account}"

          account_path = account_path(account)
          FileUtils.mkdir_p(account_path)

          Dir.chdir(heroku_path)
          File.symlink(File.join('accounts', account), CURRENT_DIR)

          Dir.glob(File.join(ssh_path, 'id_*')).each do |file|
            File.cp(file, File.join(account_path, File.basename(file)))
          end

          file = File.join(heroku_path, 'credentials')
          File.mv(file, File.join(account_path, File.basename(file)))

          Dir.glob(File.join(account_path, '*')).each do |file|
            File.symlink(
              File.join(CURRENT_DIR, File.basename(file)),
              File.basename(file)
            )
          end

          update_ssh_config
        else
          display "Usage: heroku accounts:setup account_name"
        end
      end
    end

    def update_ssh_config
      config_path = File.join(ssh_path, 'config')
      config_exists = File.exists?(config_path)
      config_done = File.read(config_path) =~ /Host\s+heroku.com/

      unless config_exists && config_done
        File.open(config_path, 'a') do |file|
          file << "\nHost heroku.com\n  IdentityFile ~/#{HEROKU_DIR}/id_rsa\n"
        end

        display "Added heroku.com to ~/.ssh/config"
      end
    end
    private :update_ssh_config

    def heroku_path
      @heroku_path ||= File.join(home_directory, HEROKU_DIR)
    end
    private :heroku_path

    def accounts_path
      @accounts_path ||= File.join(heroku_path, 'accounts')
    end
    private :accounts_path

    def account_path(account)
      File.join(accounts_path, account)
    end
    private :account_path

    def account?(account)
      if account
        File.exists?(account_path(account)).tap do |exists|
          display "Account not found: #{account}" unless exists
        end
      end
    end
    private :account?

    def ssh_path
      @ssh_path ||= File.join(home_directory, '.ssh')
    end
    private :ssh_path
  end
end

Heroku::Command::Help.group('Accounts Plugin') do |group|
  group.command('accounts', 'lists all accounts')
  group.command('accounts:add', 'adds a new account')
  group.command('accounts:switch', 'switches accounts')
  group.command('accounts:remove', 'removes a new account')
  group.command('accounts:setup', 'sets up multiple accounts')
end
