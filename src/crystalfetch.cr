require "json";
require "system/user";

class CrystalFetch
   @osname = "";
   @username = "";
   @hostname = "";
   @cpu_count = 0;
   @kernel = Kernel.new();
   @uptime = "";
   @config_path = Path.posix("crystalfetch/src/res/.config/fetchrc.json").expand();
   @rc_config = ""
   @meminfo = MemInfo.new();
   @shellname = ""
   
	struct MemInfo
		property usedMem = 0.0;
		property memTotal = 0.0;
	end
   struct Kernel
      property version = "";
      property name = "";
      property release = "";
   end

   def run()
      #load_config
      get_os;
      get_username;
      get_hostname;
      get_cpu_count;
      get_kernel_info;
      get_uptime
      get_meminfo;
      get_shellname;
      printout;
   end

   def printout()
      printf("%s@%s\n", @username.strip, @hostname.lstrip);
      puts "-----------------------"
      puts "os: #{@osname}"
      puts "Hostname: #{@hostname}"
      puts "uptime: #{@uptime}"
      puts "cpu: #{@cpu_count}"
      puts "kernel:"
      puts " - #{@kernel.name}"
      puts " - #{@kernel.release}"
      puts "Shell: #{@shellname}"
      printf("Memory: %.fmb / %.fmb\n", @meminfo.usedMem, @meminfo.memTotal);
   end

   def load_config()
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
      args = ["-o", "-m"];
		osname_s = "";
		args.each do |arg|
      	cmd_o = run_cmd(cmd, [arg]);
			osname_s = osname_s.lstrip + " " + cmd_o.strip;
		end
		@osname = osname_s;
   end

   def get_username()
      cmd = "whoami"
      @username = run_cmd(cmd);
   end

   def get_hostname()
      @hostname = System.hostname;
   end

   def get_cpu_count()
      @cpu_count = System.cpu_count.to_i32;
   end

   def get_uptime()
      cmd = "uptime";
		args = ["--pretty"]
      uptime_out = run_cmd(cmd, args);
      @uptime = uptime_out
   end

   def get_meminfo()
      meminfo_path = "/proc/meminfo"
      meminfo = File.read_lines(meminfo_path)

      memtotal = 0;
      memfree = 0;
      buffers = 0;
      cached = 0;
      shmem = 0
      usedmem = 0;
      sreclaimable = 0
      
      meminfo.each do |ln|
         if /^MemTotal:/.match(ln)
            t = /\d+/.match(ln.to_s)
            memtotal = t.to_s.to_i
         elsif /^MemFree:/.match(ln)
            t = /\d+/.match(ln.to_s)
            memfree = t.to_s.to_i
         elsif /^Shmem:/.match(ln)	
            t = /\d+/.match(ln.to_s)
            shmem = t.to_s.to_i
         elsif /^Buffers:/.match(ln)
            t = /\d+/.match(ln.to_s)
            buffers = t.to_s.to_i
         elsif /^Cached:/.match(ln)
            t = /\d+/.match(ln.to_s)	
            cached = t.to_s.to_i
         elsif /^SReclaimable:/.match(ln)
            t = /\d+/.match(ln.to_s)
            sreclaimable = t.to_s.to_i
         end
      end

		@meminfo.memTotal = memtotal / 1024;
      # MemUsed = Memtotal + Shmem - MemFree - Buffers - Cached - SReclaimable
      @meminfo.usedMem = (memtotal + shmem - memfree - buffers - cached - sreclaimable) / 1024;
   end

   def get_shellname()
      passwd_path = "/etc/passwd"
      passwd = File.read_lines(passwd_path)
      user_ln = ""
      passwd.each do |ln|
         if /#{@username.to_s.strip}/.match(ln.to_s)
            user_ln = ln.split(":")
         end
      end
      @shellname = user_ln[6].to_s
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
 
   def run_cmd(cmd, args = [""])
      stdout = IO::Memory.new();
      if args.size == 1 && args[0] == ""
         status = Process.run(
            command: cmd,
            output: stdout,
            shell: true
         );
      else
         status = Process.run(
            command: cmd,
            args: args, 
            output: stdout
         );
      end
      return stdout.to_s();
   end
end

fetch = CrystalFetch.new();
fetch.run();
