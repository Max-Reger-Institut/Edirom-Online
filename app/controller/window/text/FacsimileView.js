/**
 *  Edirom Online
 *  Copyright (C) 2014 The Edirom Project
 *  http://www.edirom.de
 *
 *  Edirom Online is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Edirom Online is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Edirom Online.  If not, see <http://www.gnu.org/licenses/>.
 */
Ext.define('EdiromOnline.controller.window.text.FacsimileView', {

    extend: 'Ext.app.Controller',

    views: [
        'window.text.FacsimileView'
    ],

    init: function() {
        this.control({
            'facsimileView': {
               afterlayout : this.onAfterLayout,
               single: true
            }
        });
    },
    
    onAfterLayout: function(view) {

        var me = this;

        if(view.initialized) return;
        view.initialized = true;

        view.on('gotoChapter', me.onGotoChapter, me);

        var uri = view.uri;

        Ext.Ajax.request({
            url: 'data/xql/getPages.xql',
            method: 'GET',
            params: {
                uri: uri,
                lang: getPreference('application_language')
            },
            success: function(response){
                var data = response.responseText;

                var pages = Ext.create('Ext.data.Store', {
                    fields: ['id', 'name', 'path', 'width', 'height', 'measures', 'annotations'],
                    data: Ext.JSON.decode(data)
                });

                view.setImageSet(pages);
            }
        });
        
        Ext.Ajax.request({
            url: 'data/xql/getChapters.xql',
            method: 'GET',
            params: {
                uri: view.uri,
                mode: 'pageMode'
            },
            success: function(response){
                var data = response.responseText;

                var chapters = Ext.create('Ext.data.Store', {
                    fields: ['id', 'name', 'pageId'],
                    data: Ext.JSON.decode(data)
                });

                me.chaptersLoaded(chapters, view);
            }
        });
    },
    
    chaptersLoaded: function(chapters, view) {
        view.setChapters(chapters);
    },
    
    onGotoChapter: function(view, pageId) {
        view.gotoPage(pageId);
    }
});
