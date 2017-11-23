var gulp = require('gulp');
var $ = require('gulp-load-plugins')();

var paths = {
    coffee: 'coffee/*.coffee',
    dist: 'dist/'
};

gulp.task('copy-config', function() {
    return gulp.src('intercom.json')
        .pipe(gulp.dest(paths.dist));
});

gulp.task('compile-coffee', function() {
    return gulp.src(paths.coffee)
        .pipe($.plumber())
        .pipe($.cached('coffee'))
        .pipe($.coffee())
        .pipe($.remember('coffee'))
        .pipe($.concat('intercom.js'))
        .pipe($.uglify({mangle:false, preserveComments: false}))
        .pipe(gulp.dest(paths.dist));
});

gulp.task('watch', function() {
    gulp.watch([paths.coffee], ['compile-coffee']);
});

gulp.task('default', ['copy-config', 'compile-coffee', 'watch']);

gulp.task('build', ['copy-config', 'compile-coffee']);
