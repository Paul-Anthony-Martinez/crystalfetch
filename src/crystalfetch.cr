require "json";

class CrystalFetch
   @os_name = "";
   @hostname = "";
   @cpu_count = 0;
   @kernel = Kernel.new();
   @rc_file = "";

   struct Kernel
      property version = ""
      property name = ""
      property release = ""
   end

   def load_config()
      file_path="res/.config/fetchrc.json"
      begin
         json=File.open(file_path) do |file|
            @rc_file = JSON.parse(file);
         end
         except = Exception.new("File not found.")
      raise except
      rescue except
         puts "#{STDERR}"
         puts "#{except}"
      end
      puts @rc_file
   end

   def run()
      get_os();
      get_hostname();
      get_cpu_count();
      get_kernel_info();
      load_config
      print_out();
   end

   def get_os()
      cmd = "uname";
      args = ["-o"];
      @os_name = run_cmd(cmd, args);
   end

   def get_hostname()
      @hostname = System.hostname;
   end

   def get_cpu_count()
      @cpu_count = System.cpu_count.to_i32;
   end

   def get_kernel_info()
      cmd = "uname";
      args = ["-s", "-v", "-r"];
      args.each do |arg|
         cmd_arg = [arg]
         cmd_out = run_cmd(cmd, cmd_arg);
         if arg == "-s"
            @kernel.name = cmd_out;
         elsif arg == "-r"
            @kernel.release = cmd_out;
         elsif arg == "-v"
            @kernel.version = cmd_out;
         end
      end
   end
 
   def run_cmd(cmd, args)
      stdout = IO::Memory.new();
      status = Process.run(
         cmd, 
         args: args, 
         output: stdout
      );
      return stdout.to_s();
   end

   def print_out()
      puts "os: #{@os_name}";
      puts "hostname: #{@hostname}";
      puts "cpu_count: #{@cpu_count}";
      puts "kernel_name: #{@kernel.name}";
      puts "kernel_release: #{@kernel.release}";
      puts "kernel_version: #{@kernel.version}";
   end
end

fetch = CrystalFetch.new();
fetch.run();
