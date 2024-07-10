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
   @memoryinfo = ""
   @shellname = ""
   
   struct Kernel
      property version = ""
      property name = ""
      property release = ""
   end

   def run()
      #load_config
      get_os();
      get_username();
      get_hostname();
      get_cpu_count();
      get_kernel_info();
      get_uptime
      get_meminfo();
      get_shellname();
      printout;
   end

   def printout()
      printf("%s@%s\n", @username.strip, @hostname.lstrip);
      puts "-----------------------"
      puts "os: #{@osname}"
      puts "uptime: #{@uptime}"
      puts "cpu: #{@cpu_count}"
      puts "kernel:"
      puts " - #{@kernel.name}"
      puts " - #{@kernel.release}"
      puts "Shell:\t#{@shellname}"
      puts "Memory: "
      #printf(" - Total:\t%.0f mb\n", @memoryinfo.split()[1].to_i / div);
      #printf(" - Free:\t%.0f bb\n", @memoryinfo.split()[4].to_i / div);
      #printf(" - Available:\t%.0f mb\n", @memoryinfo.split()[7].to_i / div);
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
      @osname = run_cmd(cmd, args);
      @osname = @osname.strip
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
      uptime_out = run_cmd(cmd);
      uptime_tmp = uptime_out.split(" ")[3].to_s
      puts uptime_tmp
      @uptime = "#{uptime_tmp.split(":")[0]}"
   end

   def get_meminfo()
      meminfo_path = "/proc/meminfo"
      meminfo = File.read_lines(meminfo_path)

      memtotal=0;
      memfree=0;
      buffers=0;
      cached=0;
      shmem=0
      usedmem=0;
      sreclaimable=0
      
      meminfo.each do |ln|
         if /MemTotal/.match(ln)
            t = /\d+/.match(ln.to_s)
            memtotal = t.to_s.to_i
         elsif /MemFree/.match(ln)
            t = /\d+/.match(ln.to_s)
            memfree = t.to_s.to_i
         elsif /Shmem/.match(ln)
            t = /\d+/.match(ln.to_s)
            shmem = t.to_s.to_i
         elsif /Buffers/.match(ln)
            t = /\d+/.match(ln.to_s)
            buffers = t.to_s.to_i
         elsif /Cached/.match(ln)
            t = /\d+/.match(ln.to_s)
            cached = t.to_s.to_i
         elsif /SReclaimable/.match(ln)
            t = /\d+/.match(ln.to_s)
            sreclaimable = t.to_s.to_i
         end
      end

      # MemUsed = Memtotal + Shmem - MemFree - Buffers - Cached - SReclaimable
      usedmem = memtotal + shmem - memfree - buffers - cached - sreclaimable
        
      puts "#{usedmem /1024}"
      puts "#{(usedmem = (usedmem /1024))/1024}"
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
