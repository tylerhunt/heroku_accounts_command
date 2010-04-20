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

Heroku::Command::Help.group('Accounts') do |group|
  group.command('account', 'lists all accounts')
  group.command('account:add', 'adds a new account')
  group.command('account:switch', 'switches accounts')
  group.command('account:remove', 'removes a new account')
end
