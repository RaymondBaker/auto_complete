import std.stdio;
import std.conv;
import std.algorithm;
import std.array: array;


struct Node {
    char val;
    Node* left;
    Node* center;
    Node* right;
    bool tail;
};

//string [] traversal(Node* node) {
//    string [] output;
//    output ~= center_traversal("", node);
//    if (node.left != null)
//        output ~= traversal(node.left);
//    if (node.right != null)
//        output ~= traversal(node.right);
//    return output;
//}

string [] traversal(Node* node, string cur_word = "") {
    string [] output;
    if (node == null)
        return [];
    output ~= traversal(node.center, cur_word ~ to!string(node.val));
    if (node.tail)
        output ~= cur_word ~ to!string(node.val);
    if (node.left != null) {
        output ~= traversal(node.left, cur_word);
    }
    if (node.right != null) {
        output ~= traversal(node.right, cur_word);
    }
    return output;
};


void make_word(char[] word, Node* node) {

    Node * cur_node = node;
    // $-1 is less either 0 or -1 which is messing with the program
    foreach (letter; word[0..$-1]) {
        cur_node.val = letter;
        cur_node.center = new Node;
        cur_node = cur_node.center;
    }

    cur_node.val = word[$-1];
    cur_node.tail = true;
}


string [] auto_complete(string word, Node* node) {
    Node* cur_node = node;
    foreach (letter; word) {
        if (cur_node.center == null && cur_node.left == null && cur_node.right == null)
            return [word];
        if (letter > node.val) {
            cur_node = cur_node.right;
            cur_node = cur_node.center;
        }
        else if (letter < node.val) {
            cur_node = cur_node.left;
            // this messes it up the word is not in the map
            cur_node = cur_node.center;
        }
        else 
            cur_node = cur_node.center;
    }
    return map!( suffix => word ~ suffix )(traversal(cur_node)).array;
}


bool add_word (char[] word, Node* node) {
    if (word.length == 0) {
        return false;
    }
    else if (node == null) {
        return true;
    } else if (word[0] == node.val) {
        if (add_word(word[1..$], node.center)) {
            node.center = new Node;
            make_word(word[1..$], node.center);
        } else {
            // root is being set as tail because of last line
            // checking this twice need to fix
            if (word.length == 1)
                node.tail = true;
        }
    } else if (word[0] > node.val) {
        if (add_word(word, node.right)) {
            node.right = new Node;
            make_word(word, node.right);
        } else {
            if (word.length == 1)
                node.tail = true;
        }
    } else {
        if (add_word(word, node.left)) {
            node.left = new Node;
            make_word(word, node.left);
        } else {
            if (word.length == 1)
                node.tail = true;
        }
    }
    return false;
}

void main() {
    Node root;
    root.val = 't';
    root.tail = false;

    add_word("test".dup, &root);
    add_word("nipples".dup, &root);
    add_word("neat".dup, &root);
    add_word("pineapple".dup, &root);

    writeln(traversal(&root, ""));
    writeln(auto_complete("ne", &root));
}
