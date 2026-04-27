import { Component } from '@angular/core';

@Component({
  selector: 'app-hello',
  imports: [],
  templateUrl: './hello.html',
  styleUrl: './hello.css',
})
export class Hello {

  protected title = 'Hello World - First Angular App';
  protected isDisabled = false;

  onClick() {
    this.isDisabled = true;
    console.log('Button clicked!');
  }

}
