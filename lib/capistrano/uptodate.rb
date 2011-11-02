Capistrano::Configuration.instance.load do

  scm               = fetch(:uptodate_scm, :git)
  scm_binary        = fetch(:uptodate_scm_bynary, 'git')
  remote_repository = fetch(:uptodate_remote_repository, 'origin')
  branch            = fetch(:uptodate_branch, 'master')
  time              = fetch(:uptodate_time, 300)
  behavior          = fetch(:uptodate_behaviour, :confirm)

  namespace :uptodate do
    desc "Automatically synchronize current repository"
    task :default do
      case scm
      when :git
        top.uptodate.git
      else
        abort("SCM #{scm} is not supported by capistrano/uptodate")
      end
    end

    task :git do
      git_dir = fetch(:uptodate_local_reposytory, `#{scm_binary} rev-parse --git-dir`.strip)
      abort "Can't detect git repository" if git_dir.empty?

      fetch_file = File.join(git_dir, "FETCH_HEAD")

      unless File.exist?(fetch_file) && Time.now - File.mtime(fetch_file) < time
        Capistrano::CLI.ui.say "Fetching references from #{repository} repository ..."
        system("#{scm_binary} fetch #{remote_repository}")
      end

      local_commit  = `#{scm_binary} rev-parse #{branch}`.strip
      remote_commit = `#{scm_binary} rev-parse #{remote_repository}/#{branch}`.strip

      if local_commit != remote_commit
        Capistrano::CLI.ui.say "Local '#{branch}' branch is not synchronized with '#{remote_repository}' repository."

        case behavior
        when :confirm
          Capistrano::CLI.ui.ask("Continue anyway? (y/N)") == 'y' or abort
        else
          abort
        end
      end
    end
  end

  on :load, 'uptodate'
end
