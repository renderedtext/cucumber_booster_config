module CucumberBoosterConfig

  class CucumberFile

    SEMAPHORE_PROFILE = "semaphoreci: --format json --out=~/cucumber_report.json"
    DEFAULT_PROFILE = "default: --format pretty --profile semaphoreci features"

    def initialize(path, dry_run)
      @path = path
      @dry_run = dry_run
    end

    def configure_for_autoparallelism
      load_file_content

      if dry_run?
        puts "Content before:"
        puts "---"
        puts @original_lines
        puts "---"
      end

      define_semaphore_profile
      include_semaphore_profile

      if dry_run?
        puts "Content after:"
        puts "---"
        puts @new_lines
        puts "---"
      else
        save_file
      end
    end

    private

    def dry_run?
      !!@dry_run
    end

    def load_file_content
      @original_lines = File.open(@path, "r") { |f| f.readlines }
      @new_lines = @original_lines
    end

    def save_file
      File.open(@path, "w") { |f| @new_lines.each { |line| f.puts line } }
    end

    def define_semaphore_profile
      puts "Inserting Semaphore configuration"

      @new_lines << "#{SEMAPHORE_PROFILE}\n"
    end

    def include_semaphore_profile
      puts "Appending Semaphore profile to default profile"

      default_profile_found = false

      @new_lines.each_with_index do |line, i|
        if line =~ /default:/
          default_profile_found = true
          line = "#{line.gsub("\n", "")} --profile semaphoreci"
        end

        @new_lines[i] = line
      end

      if !default_profile_found
        puts "No definition for default profile found, inserting new one"
        @new_lines << DEFAULT_PROFILE
      end
    end
  end
end
