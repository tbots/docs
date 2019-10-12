/*
 * Each file is referenced by an inode, which is addressed by a filesystem-unique 
 * numerical value - inode number. 
 * 
 * An inode is both a physical object located on the disk and a conceptual entity
 * represented by a data structure in the Linux kernel.
 * 
 * The inode stores the metadata associated with a file, such as the file's access
 * permissions, last access timestamp, owner, group, and size, as well the location of
 * file's data.
 */
#include <stdio.h>
