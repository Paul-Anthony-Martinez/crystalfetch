require "system"

class CrystalFetch
   def run()
      get_os()
      get_hostname()
      get_cpu_count()
   end
   def get_os()
      system("uname -a")
   end
   def get_hostname()
      name = System.hostname
      puts "#{name}"
   end
   def get_cpu_count()
      cpu_num = System.cpu_count
      puts "#{cpu_num}"
   end
end

struct Information
   property hostname;
   property cpu_count;
   property os_name;
end

# main
def main()
  fetch = CrystalFetch.new()
  fetch.run()
end

main();
