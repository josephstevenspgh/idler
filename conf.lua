function love.conf(t)
	--320
	--180
	--t.window.width = 320*4
    --t.window.height = 180*4
	t.window.width = 320*3
    t.window.height = 180*3
    t.window.title = "i d l e r"
    t.window.vsync = true
    --love-release
    t.releases = {
    title = "i d l e r",              -- The project title (string)
    package = "i d l e r",            -- The project command and package name (string)
    loveVersion = '0.10.0',        -- The project LÖVE version
    version = "0.10",            -- The project version
    author = "Joseph Stevens",             -- Your name (string)
    email = "joseph.stevens.pgh@gmail.com",              -- Your email (string)
    description = "idle!",        -- The project description (string)
    homepage = "twitter.com/splixel",           -- The project homepage (string)
    identifier = nil,         -- The project Uniform Type Identifier (string)
    releaseDirectory = "bin",   -- Where to store the project releases (string)
  }
end

