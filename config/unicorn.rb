working_directory "/var/www/moneymaker"
pid "/var/www/moneymaker/tmp/unicorn.pid"
stderr_path "/var/www/moneymaker/unicorn/unicorn.log"
stdout_path "/var/www/moneymaker/unicorn/unicorn.log"

listen "/tmp/unicorn.moneymaker.sock"
worker_processes 4
preload_app true

