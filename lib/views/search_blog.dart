import 'package:blogging_app/custom_widgets/post.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchBlog extends StatefulWidget {

  @override
  _SearchBlogState createState() => _SearchBlogState();
}

class _SearchBlogState extends State<SearchBlog> {

  TextEditingController searchEditingController = new TextEditingController();
  QuerySnapshot searchResultSnapshot;
  bool _isLoading = false;
  bool _hasUserSearched = false;

  _initiateSearch() async {
    if(searchEditingController.text.isNotEmpty){
      setState(() {
        _isLoading = true;
      });
      await DatabaseService().searchBlogPostsByName(searchEditingController.text).then((snapshot) {
        searchResultSnapshot = snapshot;
        // print(searchResultSnapshot.documents.length);
        setState(() {
          _isLoading = false;
          _hasUserSearched = true;
        });
      });
    }
  }

  Widget blogPostsList() {
    return _hasUserSearched ? (searchResultSnapshot.documents.length == 0) ?
    Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: Center(child: Text('No results found...')),
    )
        :
    ListView.builder(
        shrinkWrap: true,
        itemCount: searchResultSnapshot.documents.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              PostTile(
                  userId: searchResultSnapshot.documents[index].data["userId"],
                  blogPostId: searchResultSnapshot.documents[index].data['blogPostId'],
                  blogPostTitle: searchResultSnapshot.documents[index].data['blogPostTitle'],
                  blogPostContent: searchResultSnapshot.documents[index].data['blogPostContent'],
                  date: searchResultSnapshot.documents[index].data['date'],
                  postImage: searchResultSnapshot.documents[index].data['postImage'],
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Divider(height: 0.0)
              ),
            ],
          );
        }
    )
        :
    Container();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body:Container(
        child: SingleChildScrollView(
          child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: height * 0.06),
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.black38.withAlpha(10),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchEditingController,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                              hintText: "Search blogs...",
                              hintStyle: TextStyle(
                                color: Colors.black.withAlpha(120),
                                fontSize: 16,
                              ),
                              border: InputBorder.none
                          ),
                        ),
                      ),
                      GestureDetector(
                          onTap: (){
                            _initiateSearch();
                          },
                          child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(40)
                              ),
                              child: Icon(Icons.search, color: Colors.white)
                          )
                      )
                    ],
                  ),
                ),
                _isLoading ? Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                  child: Center(child: CircularProgressIndicator()),
                ) : blogPostsList()
              ]
          ),
        ),
      ),
    );
  }
}