import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';


class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
      id: '',
      title: '',
      price: 0,
      description: '',
      imageUrl: ''
  );
  var _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': ''
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
       if(productId != ''){
         _editedProduct =
             Provider.of<Products>(context, listen: false).findById(productId);
         _initValues = {
           'title': _editedProduct.title,
           'description': _editedProduct.description,
           'price': _editedProduct.price.toString(),
           // 'imageUrl': _editedProduct.imageUrl,
           'imageUrl': '',
         };
         _imageUrlController.text = _editedProduct.imageUrl;
       }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose(){
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl(){
    if(!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg'))) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() async{
    final isValid = _form.currentState!.validate();
    if(!isValid){
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if(_editedProduct.id != ''){
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    }
    else{
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      }catch(error){
        await showDialog(
          context: context,
          builder: (ctx) =>
            AlertDialog(
              title: const Text('Ocurrio un error'),
              content: const Text('...'), //Text(error.toString())
              actions: [
                TextButton(onPressed: () {
                  Navigator.of(ctx).pop();
                }, child: const Text('Ok'))
              ],
            )
        );
      }
      // finally{
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Edicion'),
        actions: [
          IconButton(
            onPressed: _saveForm,
              icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initValues['title'].toString(),
                decoration: const InputDecoration(labelText: 'Titulo'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                validator: (value){
                  if(value!.isEmpty) {
                    return 'Por favor ingresa un titulo';
                  }
                  return null;
                },
                onSaved: (value){
                  _editedProduct = Product(
                  id: _editedProduct.id,
                  title: value.toString(),
                  price: _editedProduct.price,
                  description: _editedProduct.description,
                  imageUrl: _editedProduct.imageUrl,
                  isFavorite: _editedProduct.isFavorite
                  );
                },
              ),
              TextFormField(
                initialValue: _initValues['price'].toString(),
                decoration: const InputDecoration(labelText: 'Precio'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                  onFieldSubmitted: (_){
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: _editedProduct.title,
                    price: double.parse(value!),
                    description: _editedProduct.description,
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite
                  );
                },
                validator: (value){
                  if(value!.isEmpty) {
                    return 'Por favor ingresa un precio';
                  }
                  if(double.tryParse(value)==null) {
                    return 'Ingresa un valor valido';
                  }
                  if(double.parse(value) <= 0) {
                    return 'Por favor un numero mayor a cero';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValues['description'].toString(),
                decoration: const InputDecoration(labelText: 'Descripcion'),
                maxLines: 3,
                focusNode: _descriptionFocusNode,
                keyboardType: TextInputType.multiline,
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: _editedProduct.title,
                    price: _editedProduct.price,
                    description: value.toString(),
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite
                  );
                },
                validator: (value){
                  if(value!.isEmpty) {
                    return 'Por favor ingresa una descripcion';
                  }
                  if(value.length < 10) {
                    return 'Debe tener almenos 10 caracteres';
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 1,
                          color: Colors.grey
                      )
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? const Text('Ingresa URL')
                        : FittedBox(child: Image.network(
                      _imageUrlController.text,
                      fit: BoxFit.cover,
                    ),),
                  )
                ],
              ),
              Expanded(
                child: TextFormField(
                decoration: const InputDecoration(labelText: 'Image URL'),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                controller: _imageUrlController,
                focusNode: _imageUrlFocusNode,
                onFieldSubmitted: (_) {
                   _saveForm();
                },
                validator: (value){
                  if(value!.isEmpty) {
                    return 'Por favor ingresa una URL';
                  }
                  if(!value.startsWith('http') && !value.startsWith('https')) {
                    return 'Ingresa una URL valida';
                  }
                  if(!value.endsWith('.png') && !value.endsWith('.jpg')) {
                    return 'Ingresa una imagen valida .png o .jpg';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: _editedProduct.title,
                    price: _editedProduct.price,
                    description: _editedProduct.description,
                    imageUrl: value.toString(),
                    isFavorite: _editedProduct.isFavorite
                  );
                  }
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
