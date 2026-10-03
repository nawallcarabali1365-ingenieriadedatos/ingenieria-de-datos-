create database tienda_tecno
	with encoding = 'UTF8'
	template = template0;
	
	
*/ crear tablas*/
create table clientes(
idcliente serial primary key,
nombrecliente varchar(50) not null,
correocliente varchar(120) not null unique,
fecharegidtro date not null default current_date
);

create table Producto(
idProducto serial primary key,
nombreProducto varchar (100) not null,
precioProducto numeric(10,2) not null check (precioProducto>0),
stock integer not null default 0
);


create table Pedido(
idPedido serial primary key,
idclienteFK integer not null references clientes(idcliente) on delete cascade , 
fechapedido timestamp not null default now (),
estadoPedido varchar (20) not null default 'pendiente'
);


create table Detalle_Pedido(
idPedidoFK integer not null references  Pedido(idPedido) on delete cascade,
idProductoFK integer not null references Producto (idProducto)  on delete cascade,
cantidad integer not null check (cantidad>0),
primary key (idPedidoFK,idProductoFK )
);


/* tarea tabla cliente*/
alter table clientes
add telefonocliente varchar (34)
;

/*cambiar columna de nombre producto*/
alter table Producto alter column  nombreProducto type varchar(150) ;

/*renombrar columna estado pedido*/
alter table Pedido rename column estadoPedido to estado ;

/*poner restriccion del stock */
alter table Producto
add constraint Producto check (stock >= 0) ;
 