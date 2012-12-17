working_directory "/var/www/moneymaker"
pid "/var/www/moneymaker/tmp/unicorn.pid"
stderr_path "/var/www/moneymaker/unicorn/unicorn.log"
stdout_path "/var/www/moneymaker/unicorn/unicorn.log"

listen "127.0.0.1:8080"
worker_processes 4
preload_app true

