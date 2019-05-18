import std.stdio;
import std.conv;
import std.algorithm;
import std.array: array;
import std.string : format;


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
    int i = 0;
    while (i < word.length) {
        auto letter = word[i];
        if (cur_node == null) {
            stderr.writeln("Failure in auto complete: ended on null node");
            return [word];
        }
        if (cur_node.center == null && cur_node.left == null && cur_node.right == null)
            return [word];

        if (letter > cur_node.val) {
            cur_node = cur_node.right;
        }
        else if (letter < cur_node.val) {
            cur_node = cur_node.left;
        }
        else {
            cur_node = cur_node.center;
            i++;
        }
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

int main(string [] args) {

    if (args.length < 2) {
        stderr.writeln(args.length);
        stderr.writeln("Please give a word to autocomplete.\nauto_complete <word> <word> ...");
        return 1;
    }


    Node root;
    root.val = 't';
    root.tail = false;

    auto file = File("words.txt");
    auto range = file.byLine();


    int words_loaded = 0;
    foreach (line; range)
    {
        if (line.length > 0) {
            add_word(line, &root);
            words_loaded++;
        }
    }

    writeln("loaded %s words".format(words_loaded));

    //add_word("nipples".dup, &root);
    //add_word("neat".dup, &root);
    //add_word("pineapple".dup, &root);

    //writeln(traversal(&root));
    foreach (word; args[1..$])
        writeln(auto_complete(word, &root));
    return 0;
}
