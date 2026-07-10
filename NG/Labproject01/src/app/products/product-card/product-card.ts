import { Component, input } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { ProductInterface } from '../product-interface';

@Component({
  selector: 'app-product-card',
  imports: [MatCardModule, MatButtonModule],
  templateUrl: './product-card.html',
  styleUrl: './product-card.css',
})
export class ProductCard {

  readonly product = input.required<ProductInterface>();
  readonly addButtonLabel = input<string>('Add to Cart');
  //@Input({required: true}) product!: ProductInterface;
}
