#-----------------------------------#
# Place true or false to enable ora #
# disable the information that fetch#
# will display!                     #
#-----------------------------------#
{
   "os_name": true,
   "hostname": true,
   "cpu_count": true
}
#-----------------------------------#
class CrystalFetch
   @os_name = "";
   @hostname = "";
   @cpu_count = 0;
   @kernel = {
      name => "",
      release => 0
   }
   def run()
      get_os();
      get_hostname();
      get_cpu_count();
      print_out();
   end
   def get_os()
      cmd = "uname";
      args = ["-s"];
      stdout = IO::Memory.new();
      stderr = IO::Memory.new();
      status = Process.run(cmd, args: args, output: stdout);
      @os_name = stdout.to_s();
   end
   def get_hostname()
      @hostname = System.hostname;
   end
   def get_cpu_count()
      @cpu_count = System.cpu_count.to_i32;
   end
   def print_out()
      puts "os: #{@os_name}";
      puts "hostname: #{@hostname}";
      puts "cpu_count: #{@cpu_count}";
   end
end

fetch = CrystalFetch.new();
fetch.run();
