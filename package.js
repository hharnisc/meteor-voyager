Package.describe({
  summary: 'voyager',
  version: "0.1.1",
  git: "https://github.com/hharnisc/meteor-voyager.git"
});

Package.on_use(function (api) {
  api.versionsFrom("METEOR@0.9.0");
    api.use('coffeescript');
    api.use("mrt:server-stats@0.1.0", 'server');
    api.export('Voyager', 'server');

  // Generated with: github.com/philcockfield/meteor-package-loader
  api.add_files('server/voyager.coffee', 'server');

});
