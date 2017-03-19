module CucumberBoosterConfig

  class CucumberFile

    DEFAULT_PROFILE = "default: --format pretty --profile semaphoreci features"

    def initialize(path, dry_run)
      @path = path
      @dry_run = dry_run
    end

    def configure_for_autoparallelism(report_path)
      load_file_content

      if dry_run?
        puts "Content before:"
        puts "---"
        puts @original_lines
        puts "---"
      end

      define_semaphore_profile(report_path)
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

    def define_semaphore_profile(report_path)
      puts "Inserting Semaphore configuration for json report"
      puts "Report path: #{report_path}"

      @new_lines << "semaphoreci: --format json --out=#{report_path}\n"
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
