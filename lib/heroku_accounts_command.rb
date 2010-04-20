require 'fileutils'

module Heroku::Command
  class Accounts < BaseWithApp
    def index
      setup

      Dir[File.join(accounts_directory, '*')].each do |path|
        display File.basename(path)
      end
    end

    def add
    end

    def switch
    end

    def remove
    end

    def setup
      unless File.directory?(accounts_directory)
        FileUtils.mkdir_p(accounts_directory)
      end
    end
    private :setup

    def accounts_directory
      @accounts_directory ||= File.join(home_directory, '.heroku', 'accounts')
    end
  end
end

Heroku::Command::Help.group('Accounts Plugin') do |group|
  group.command('accounts', 'lists all accounts')
  group.command('accounts:add', 'adds a new account')
  group.command('accounts:switch', 'switches accounts')
  group.command('accounts:remove', 'removes a new account')
end
