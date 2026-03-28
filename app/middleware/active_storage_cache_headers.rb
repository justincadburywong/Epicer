class ActiveStorageCacheHeaders
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    if env["PATH_INFO"] =~ %r{/rails/active_storage/}
      headers["Cache-Control"] = "public, max-age=31536000, immutable"
    end

    [ status, headers, body ]
  end
end
