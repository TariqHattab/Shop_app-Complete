import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit_product_screen';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  var _priceFocuseNode = FocusNode();
  var _descriptionFocuseNode = FocusNode();
  var _imageUrlFocuseNode = FocusNode();

  var _imageUrlController = TextEditingController(text: '');
  var _titleController = TextEditingController(text: '');
  var _priceController = TextEditingController(text: '0');
  var _descriptionController = TextEditingController(text: '');

  var _form = GlobalKey<FormState>();
  var _isLoading = false;
  var _id;
  var _isFavorite;

  Product _editedProduct;

  @override
  void dispose() {
    _priceFocuseNode.dispose();
    _descriptionFocuseNode.dispose();
    _imageUrlFocuseNode.dispose();

    _imageUrlController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      var id = ModalRoute.of(context).settings.arguments as Map<String, String>;
      if (id == null) {
        return;
      }
      Product myProduct =
          Provider.of<Products>(context, listen: false).findById(id['id']);
      //_editedProduct = myProduct.copyWith();
      //print(_editedProduct.title);
      _id = myProduct.id;
      _isFavorite = myProduct.isFavorite;
      _titleController.text = myProduct.title;
      _priceController.text = myProduct.price.toStringAsFixed(1);
      _descriptionController.text = myProduct.description;
      _imageUrlController.text = myProduct.imageUrl;
    });
  }

  void _saveForm() async {
    // _form.currentState.save();  // to trigger onSave: in each input in the form
    var isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    setState(() {
      //start the loading spinner
      _isLoading = true;
    });
    if (_id != null) {
      try {
        //update the product
        await Provider.of<Products>(context, listen: false).updateProduct(
            _id,
            Product(
              id: _id,
              isFavorite: _isFavorite,
              title: _titleController.text,
              price: double.parse(_priceController.text),
              description: _descriptionController.text,
              imageUrl: _imageUrlController.text,
            ));
        print('Succeeded');
      } catch (e) {
        print('updating product failed ');
      }
    } else {
      try {
        //add the product
        await Provider.of<Products>(context, listen: false).addProduct(Product(
            id: DateTime.now().toString(),
            title: _titleController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            imageUrl: _imageUrlController.text));
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('an erorr occured'),
                content: Text(error.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Ok'))
                ],
              );
            });
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  String _validateNotEmpty(String value) {
    if (value.isEmpty) {
      return 'must not be empty!';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Edit the product'),
          actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))]),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _form,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      validator: _validateNotEmpty,
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocuseNode);
                      },
                    ),
                    TextFormField(
                      validator: _validateNotEmpty,
                      controller: _priceController,
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocuseNode,
                    ),
                    TextFormField(
                      validator: _validateNotEmpty,
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocuseNode,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 2),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('enter an Image Url')
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            validator: _validateNotEmpty,
                            decoration: InputDecoration(labelText: 'Image Url'),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.url,
                            controller: _imageUrlController,
                            onEditingComplete: _saveForm,
                            focusNode: _imageUrlFocuseNode,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
