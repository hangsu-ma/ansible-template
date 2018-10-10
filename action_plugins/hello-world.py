# Copyright: (c) 2018, Hangsu Ma (hangsu@beag.biz)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.plugins.action import ActionBase
from ansible.utils.vars import merge_hash
from ansible.errors import AnsibleError


class ActionModule(ActionBase):
    def run(self, tmp=None, task_vars=None):
        self._supports_check_mode = True
        if task_vars is None:
            task_vars = dict()
        results = super(ActionModule, self).run(tmp, task_vars)

        if self._task.args.get('state', 'present') == 'present':
            file_module_args = dict()
            file_module_args['path'] = self._task.args.get('temp_path', '/tmp')
            file_module_args['owner'] = task_vars.get('vars').get('user','root')
            file_module_args['group'] = task_vars.get('vars').get('group','root')
            file_module_args['state'] = 'directory'
            self._update_module_args('file',file_module_args,task_vars)
            results.update(self._execute_module(module_name='file', module_args=file_module_args, task_vars=task_vars))
            if results.get('failed'):
                raise AnsibleError("preparing temp folder: %s failed with msg: %s " % (file_module_args['path'],results.get('msg')))

            template_task = self._task.copy()
            template_task.args.clear()
            template_task.args.update(
                dict(
                    src=self._task.args.get('file', 'templates/place_holder.j2'),
                    dest="%s/place_holder" % self._task.args.get('temp_path', '/tmp'),
                    owner=self._task.args.get('user', 'root'),
                    group=self._task.args.get('group', 'root'),
                    force=True
                )
            )
            template_action = self._shared_loader_obj.action_loader.get('template',
                                                                    task=template_task,
                                                                    connection=self._connection,
                                                                    play_context=self._play_context,
                                                                    loader=self._loader,
                                                                    templar=self._templar,
                                                                    shared_loader_obj=self._shared_loader_obj)
            results.update(template_action.run(task_vars=task_vars))
            if results.get('failed'):
                raise AnsibleError("preparing installation files failed with msg: %s " % (results.get('msg')))

        results = merge_hash(
            results,
            self._execute_module(tmp=tmp, module_name='hello-world', task_vars=task_vars),
        )
        return results