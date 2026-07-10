import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';

import { Lista } from './pages/lista/lista';

import {
  PoMenuItem,
  PoMenuModule,
  PoPageModule,
  PoToolbarModule,
} from '@po-ui/ng-components';

@Component({
  selector: 'app-root',
  imports: [
    CommonModule,
    PoToolbarModule,
    PoMenuModule,
    PoPageModule,    
    Lista
  ],
  templateUrl: './app.html',
  styleUrls: ['./app.css'],
})
export class App {
  readonly menus: Array<PoMenuItem> = [
    { label: 'Home', action: this.onClick.bind(this), icon: 'po-icon-home' },
  ];

  private onClick() {
    alert('Clicked in menu item');
  }
}
