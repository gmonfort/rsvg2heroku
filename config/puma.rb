workers Integer(ENV.fetch("PUMA_WORKERS", 3))
threads Integer(ENV.fetch("MIN_THREADS", 10)),
  Integer(ENV.fetch("MAX_THREADS", 10))

preload_app!

rackup      DefaultRackup
port        ENV.fetch("PORT", 3000)
environment ENV.fetch("RACK_ENV", "development")

on_worker_boot do
  # Force reconnection for each worker
  DB.disconnect
end
