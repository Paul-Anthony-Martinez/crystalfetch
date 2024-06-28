require "json";

class CrystalFetch
   @os_name = "";
   @hostname = "";
   @cpu_count = 0;
   
   @kernel = Kernel.new();
   @uptime = Uptime.new();
   
   @config_path = Path.posix("crystalfetch/src/res/.config/fetchrc.json").expand();
   
   struct Kernel
      property version = ""
      property name = ""
      property release = ""
   end
   
   struct Uptime
      property up = 0.0
      property idle = 0.0
   end

   @rc_config = ""

   def run()
      #load_config
      get_os();
      get_username();
      get_hostname();
      get_cpu_count();
      get_kernel_info();
      get_uptime
   end

   def load_config()
      puts @config_path
      begin
         json = File.open(@config_path) do |file|
            file = JSON.parse(file);
            #@rc_config = file.as_h
         end
      rescue except
         puts "#{STDERR}"
         puts "#{except}"
      end
   end

   def get_os()
      cmd = "uname";
      args = ["-o"];
      @os_name = run_cmd(cmd, args);
   end

   def get_username()
      cmd = "whoami"
      args = [" "]

      @hostname = run_cmd(cmd, args);
      puts "Host: #{@hostname}"
   end

   def get_hostname()
      @hostname = System.hostname;
   end

   def get_cpu_count()
      @cpu_count = System.cpu_count.to_i32;
   end

   def get_uptime()
      uptime_path = "/proc/uptime"
      upt = content = File.open(uptime_path) do |file|
         file.gets_to_end
      end
      
      time = upt.split();
      @uptime.up = time[0].to_f
      @uptime.idle = time[1].to_f
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
         command: cmd,
         args: args, 
         output: stdout
      );
      return stdout.to_s();
   end
end

fetch = CrystalFetch.new();
fetch.run();
