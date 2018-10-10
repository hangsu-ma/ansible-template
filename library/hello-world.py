#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2018, Hangsu Ma (hangsu@beag.biz)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function

__metaclass__ = type

ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'Hangsu Ma'}

DOCUMENTATION = '''
---
module: hello-world
short_description: ansible module development boilerplate
description:
    - copy the template file to remote and add appended current run tim.
version_added: "1.0"
notes:
    - This module is a boilerplate to serve as a template
options:
    file:
        description: 
            - the template file to copy to remotes
author:
    - "Hangsu Ma (hangsu@beag.biz)"
'''

EXAMPLES = '''
- name: demo
  hello-world:
    greeting:  hello world sandbox
    file: templates/place_holder.j2
    user: root
    group: root

'''

from ansible.module_utils.basic import AnsibleModule


def execute_script(module, result, cmd):
    rc, stout, err = module.run_command(cmd)
    logs = result['logs']
    logs.append("return code: %s" % rc)
    logs.append("stout: %s" % stout)
    logs.append("sterr: %s" % err)


def main():
    module_args = dict(
        greeting=dict(type='str', default='doh'),
        file=dict(type='str', default='templates/place_holder.j2'),
        user=dict(type='str', default='root'),
        group=dict(type='str', default='root'),
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    result = dict(
        changed=False,
        msg='',
        logs=[]
    )

    execute_script(module,result, "cp /tmp/place_holder /tmp/changed_by_module")
    module.exit_json(**result)


if __name__ == '__main__':
    main()
