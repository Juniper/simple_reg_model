module Shell;
  require 'open3'
  require 'rainbow'
  
  def self.sh(cmd)
    system("rm -rf stdout.txt")
    system("rm -rf stderr.txt")
    command = cmd.split[0] 
    begin 
      puts Rainbow("\nRunning  #{cmd}\n").bright
      stdout, stderr, status = Open3.capture3(cmd)
    rescue
      abort(Rainbow("\nCommand \"#{command}\" threw an exception. Check if the path is correct").bright.red)
    end

    if status.success?
      puts Rainbow("\nSuccessfully ran cmd\n").green
      stdout.split(/\n/).each do |line|
        yield line if block_given?
      end
      true
    else
      $stderr.puts(Rainbow("\nProblem running #{cmd}\n").bright);
        
      $stderr.puts(Rainbow("\nStoring output of command in stdout.txt stderr.txt\n").bright);
      File.open('stdout.txt', "w") do |fh|
        fh.write(stdout)
      end
      File.open('stderr.txt', "w") do |fh|
        fh.write(stderr)
      end
      abort Rainbow("Command \"#{command}\" FAILED:Terminating the program").bright.red
    end
  end

  def self.parse_verilog_log(logfile)
    lines = []
    File.open(logfile).each do |line|
      lines << line if line =~ /^SRUN_TEST/
    end
    lines
  end

  def self.parse_unit_test_result(logfile)
    lines = []
    File.open(logfile).each do |line|
      if line =~ /^UnitTestRun/
        a = line.split(":")
        prefix, full_path, line, testname, result = a
        filename = File.basename(full_path)
        if result =~ /PASS/
          result = Rainbow("#{result}").bright.green
        else
          result = Rainbow("#{result}").bright.red
        end 
        lines << "#{filename}:#{line}:#{testname}:#{result}"
      end
    end
    lines
  end
end
    
