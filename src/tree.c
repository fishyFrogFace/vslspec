#include <vslc.h>
#include <stdarg.h>


void
node_print ( node_t *root, int nesting )
{
    if ( root != NULL )
    {
        /* Print the type of node indented by the nesting level */
        printf ( "%*c%s", nesting, ' ', node_string[root->type] );

        /* For identifiers, strings, expressions and numbers,
         * print the data element also
         */
        if ( root->type == IDENTIFIER_DATA ||
             root->type == STRING_DATA ||
             root->type == EXPRESSION ) 
            printf ( "(%s)", (char *) root->data );
        else if ( root->type == NUMBER_DATA )
            printf ( "(%ld)", *((int64_t *)root->data) );

        /* Make a new line, and traverse the node's children in the same manner */
        putchar ( '\n' );
        for ( int64_t i=0; i<root->n_children; i++ )
            node_print ( root->children[i], nesting+1 );
    }
    else
        printf ( "%*c%p\n", nesting, ' ', root );
}


/* Take the memory allocated to a node and fill it in with the given elements */
node_t *
node_init (node_t *nd, node_index_t type, void *data, uint64_t n_children, ...)
{
    nd->type = type;
    nd->data = data;
    nd->children = (node_t **) malloc(n_children*sizeof(node_t *));
    va_list arglist;
    va_start(arglist, n_children);
    for (uint64_t n = 0; n < n_children; n++) {
        nd->children[n] = va_arg(arglist, node_t *);
    }
    va_end(arglist);
    return nd;
}

node_t *
make_node (node_index_t type, void *data, uint64_t n_children, ...)
{
    node_t *locNd = (node_t *) malloc(sizeof(node_t));
    va_list arglist;
    node_t *nd = node_init(locNd, type, &data, n_children, arglist);;
    return nd;
}

/* Remove a node and its contents */
void
node_finalize ( node_t *discard ) {
    free(discard);
}

/* Recursively remove the entire tree rooted at a node */
void
destroy_subtree ( node_t *discard ) {
    for (uint64_t n = 0; n < discard->n_children; n++) {
        node_finalize(discard->children[n]);
    }   
    free(discard);
    free(discard->children);
}
