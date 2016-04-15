#TODO: Autodoc for D would be nice

from docutils import nodes
from docutils.parsers.rst import directives

from sphinx import addnodes
from sphinx.roles import XRefRole
from sphinx.locale import l_
from sphinx.domains import Domain, ObjType, Index
from sphinx.directives import ObjectDescription
from sphinx.util.nodes import make_refnode

DLANG = 'd'
DOC_METAFILE = 'docs.json'

def make_dlang_block(code):
    node = nodes.literal_block(code, code)
    node['language'] = DLANG
    return node

class DModule(ObjectDescription):
    """
    Directive to mark description of a new module.
    """
    has_content = False
    required_arguments = 1
    optional_arguments = 0
    final_argument_whitespace = False
    option_spec = {
        'noindex': directives.flag,
    }

    def run(self):
        env = self.state.document.settings.env
        modname = self.arguments[0]
        env.temp_data['d:scope'] = modname.strip()

        ret = []
        if 'noindex' not in self.options:
            env.domaindata['d']['objects'][modname] = (env.docname, 'module')
            #TODO: Add Indexing
            #index_node = addnodes.index([('single', modname,
            #                              'd:mod:' + modname, modname)])
            #ret.append(index_node)

        return ret

class DObject(ObjectDescription):
    has_content = True
    required_arguments = 1
    final_argument_whitespace = True

    option_spec = {
        'name': directives.unchanged,
        'noindex': directives.flag,
    }

    def run(self):
        env = self.state.document.settings.env

        if 'name' in self.options:
            self.name = self.options['name']
        else:
            self.name = self.infer_name()

        fullname = self.get_fullname(self.name)

        if 'noindex' not in self.options:
            env.domaindata['d']['objects'][fullname] = (env.docname, self.get_objtype())

        return ObjectDescription.run(self)

    def get_fullname(self, name):
        temp_data = self.state.document.settings.env.temp_data

        if 'd:scope' in temp_data:
            return temp_data['d:scope'] + '.' + name
        return name

    def infer_name(self):
        raise NotImplementedError()

    def get_objtype(self):
        raise NotImplementedError()

class DClass(DObject):
    def run(self):
        ret = DObject.run(self)

        env = self.state.document.settings.env
        env.temp_data['d:scope'] += '.' + self.name

        return ret

    def infer_name(self):
        return self.arguments[0].split(' ')[1].split('(')[0]

    def get_objtype(self):
        return'class'

class DStruct(DClass):
    def get_objtype(self):
        return'struct'

class DInterface(DClass):
    def get_objtype(self):
        return 'interface'

class DFunction(DObject):
    def infer_name(self):
        return 'TODO'

    def get_objtype(self):
        return'function'

class DAlias(DObject):
    def infer_name(self):
        return 'TODO'

    def get_objtype(self):
        return 'alias'

class DEnum(DObject):
    def infer_name(self):
        return 'TODO'

    def get_objtype(self):
        return 'enum'

class DVariable(DObject):
    def infer_name(self):
        return self.arguments[0].split(' ')[1]

    def get_objtype(self):
        return 'variable'

class DXRefRole(XRefRole):
    def __init__(self, target_type):
        XRefRole.__init__(self)

        self.target_type = target_type

    def process_link(self, env, refnode, has_explicit_title, title, target):
        refnode['d:scope'] = env.temp_data.get('d:scope')

        return title, 'd:{}:{}'.format(self.target_type, target)

class DDomain(Domain):
    name = 'd'
    label = 'Dlang'

    object_types = {
        'module':    ObjType(l_('module'),    'mod',    'obj'),
        'class':     ObjType(l_('class'),     'class',  'obj'),
        'struct':    ObjType(l_('struct'),    'struct', 'obj'),
        'interface': ObjType(l_('interface'), 'inter',  'obj'),
        'function':  ObjType(l_('function'),  'func',   'obj'),
        'alias':     ObjType(l_('alias'),     'alias',  'obj'),
        'enum':      ObjType(l_('enum'),      'enum',   'obj'),
        'variable':  ObjType(l_('variable'),  'var',    'obj'),
    }

    directives = {
        'module':    DModule,
        'class':     DClass,
        'struct':    DStruct,
        'interface': DInterface,
        'function':  DFunction,
        'alias':     DAlias,
        'enum':      DEnum,
        'variable':  DVariable,
    }

    roles = {
        'mod':    DXRefRole('mod'),
        'class':  DXRefRole('class'),
        'struct': DXRefRole('struct'),
        'inter':  DXRefRole('inter'),
        'func':   DXRefRole('func'),
        'alias':  DXRefRole('alias'),
        'enum':   DXRefRole('enum'),
        'var':    DXRefRole('var'),
    }

    initial_data = {
        'objects': {},  # fullname -> docname, type
    }

    def resolve_xref_names():
        pass

    def resolve_xref(self, env, fromdocname, builder,
                     type, target, node, contnode):
        scope = node.get('d:scope', None)
        target_name = target.split(':')[2]

        for name in target_name, scope + '.' + target_name:
            if name in self.data['objects']:
                todocname = self.data['objects'][name][0]
                return make_refnode(builder, fromdocname, todocname, target, contnode, name)
        return None

def setup(app):
    app.add_domain(DDomain)
