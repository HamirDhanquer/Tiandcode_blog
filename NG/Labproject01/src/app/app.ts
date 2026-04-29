import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
//import { Hello } from './hello/hello';
import { Header } from './header/header';
import { ProductsGrid } from './products/products-grid/products-grid';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, Header, ProductsGrid],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('Labproject01');
}
