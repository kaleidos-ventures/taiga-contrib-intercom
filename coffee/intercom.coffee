###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: call-to-action.coffee
###

IntercomDirective = ($config, $analytics) ->
    initialized = false

    refreshUser = (user) ->
        if user
            window.Intercom('boot', {
                app_id: $config.get('intercomApiKey'),
                email: user.email,
                user_id: user.id,
                created_at: user.date_joined,
                analytics_id: user.uuid,
            })
        else
            window.Intercom('boot', {app_id: $config.get('intercomApiKey')})

    patchAnalytics = () ->
        trackPage = $analytics.trackPage.bind($analytics)
        $analytics.trackPage = (url, title) ->
            trackPage(url, title)
            return if not initialized
            return if not window.Intercom
            window.Intercom('trackEvent', 'pageview', {url, title})

        trackEvent = $analytics.trackEvent.bind($analytics)
        $analytics.trackEvent = (category, action, label, value) ->
            trackEvent(category, action, label, value)
            return if not initialized
            return if not window.Intercom
            window.Intercom('trackEvent', "#{category} #{action}", {category, action, label, value})

    link = ($scope, $el, $attrs) ->
        patchAnalytics($analytics)

        $scope.$on "auth:login", refreshUser
        $scope.$on "auth:logout", refreshUser
        $scope.$on "auth:register", refreshUser
        $scope.$on "auth:refresh", refreshUser
        $scope.$on "loader:end", () ->
            if initialized
                return

            initialized = true

            if typeof window.Intercom == "function"
                window.Intercom('reattach_activator')
                window.Intercom('update',intercomSettings)
            else
                i = () ->
                    i.c(arguments)
                i.q = []
                i.c = (args) -> i.q.push(args)
                window.Intercom = i
                s = document.createElement('script')
                s.type = 'text/javascript'
                s.async = true
                s.src = 'https://widget.intercom.io/widget/' + $config.get('intercomApiKey')
                x = document.getElementsByTagName('script')[0]
                x.parentNode.insertBefore(s,x)

            refreshUser($scope.user)

    return {
        restrict: "E"
        link: link
    }

module = angular.module('intercomPlugin', [])
module.directive("body", ["$tgConfig", "$tgAnalytics", IntercomDirective])
