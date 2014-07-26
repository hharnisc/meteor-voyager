Package.describe({
  summary: 'voyager'
});

Npm.depends({
    'ddp': '0.7.0'
});

Package.on_use(function (api) {
    api.use('coffeescript');
    api.use('server-stats', 'server');
    api.export('Voyager', 'server');

  // Generated with: github.com/philcockfield/meteor-package-loader
  api.add_files('server/voyager.coffee', 'server');

});
