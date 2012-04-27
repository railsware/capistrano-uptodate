Capistrano::Configuration.instance(true).load do

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
      # skip if no git dir detected
      git_dir = fetch(:uptodate_local_reposytory, `#{scm_binary} rev-parse --git-dir`.strip)
      next if git_dir.empty?

      # skip if remote is not yet configured
      remote_reference_file = File.join(git_dir, 'refs', 'remotes', remote_repository, branch)
      next unless File.exists?(remote_reference_file)

      # fetch remote references and skip on error
      fetch_file = File.join(git_dir, "FETCH_HEAD")
      unless File.exist?(fetch_file) && Time.now - File.mtime(fetch_file) < time
        Capistrano::CLI.ui.say "Fetching references from #{remote_repository} repository ..."
        next unless system("#{scm_binary} fetch #{remote_repository}")
      end

      # get commit for local and remote reference
      local_commit  = `#{scm_binary} rev-parse #{branch}`.strip
      remote_commit = `#{scm_binary} rev-parse #{remote_repository}/#{branch}`.strip

      # compare local and remote commit
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
