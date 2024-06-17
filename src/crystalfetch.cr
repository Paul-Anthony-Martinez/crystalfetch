#------------------------------------#
# Place true or false to enable or   #
# disable the information that fetch #
# will display!                      #
#------------------------------------#
{
   "os_name": true,
   "hostname": true,
   "cpu_count": true,
   "kernel": {
      "name": true,
      "version": true,
      "release": true
   }
}
#-----------------------------------#
class CrystalFetch
   @os_name = "";
   @hostname = "";
   @cpu_count = 0;
   @kernel = Kernel.new();
   struct Kernel
      property version = ""
      property name = ""
      property release = ""
   end
   def run()
      get_os();
      get_hostname();
      get_cpu_count();
      get_kernel_info();
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
      args = ["-s"];
      @kernel.name = run_cmd(cmd, args);
   end
##########################################
   def run_cmd(cmd, args)
      stdout = IO::Memory.new();
      status = Process.run(
         cmd, 
         args: args, 
         output: stdout
      );
      return stdout.to_s();
   end
##########################################

   def print_out()
      puts "os: #{@os_name}";
      puts "hostname: #{@hostname}";
      puts "cpu_count: #{@cpu_count}";
      puts "kernel_name: #{@kernel.name}";
   end
end

fetch = CrystalFetch.new();
fetch.run();
