import { Component, input, output } from '@angular/core';
import { 
  PoListViewModule, 
  PoButtonModule,
  PoContainerModule
} from '@po-ui/ng-components';

@Component({
  selector: 'app-lista',
  imports: [PoListViewModule, PoButtonModule, PoContainerModule],
  templateUrl: './lista.html',
  styleUrl: './lista.css',
})
export class Lista {

  minhaLista: string = "Minha Lista, PO UI, Angular, TypeScript";
  listaFrutas 
  //Texto = output<string>();
  //Texto2 = input<string>("TESTE");

  ngOnInit() {
  
   
   // console.log(this.minhaLista + this.Texto2());
  }

  NovaLista(){
    this.minhaLista = "Nova Lista, SQL, MongoDB, PostgreSQL";
  }

  NovoTexto() {
    
   // this.Texto.emit("Novo Texto");
    //this.Texto = "Novo Texto";
  }
}
