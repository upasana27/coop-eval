#!/bin/bash
env="Overcooked"

# unident_s, random1, random3, distant_tomato, many_orders
layout="random3"

version="old"
if [[ "${layout}" == "distant_tomato" || "${layout}" == "many_orders" ]]; then
    version="new"
fi

num_agents=2
algo="population"
agent0_policy_name="script:random3_only_onion_to_middle"
agent1_policy_name="script:random3_only_onion_to_middle"
exp="eval-${agent0_policy_name}-${agent1_policy_name}"

path=../policy_pool
population_yaml_path=${path}/${layout}/fcp/s2/eval.yml

export POLICY_POOL=${path}

echo "env is ${env}, layout is ${layout}, algo is ${algo}, exp is ${exp}, max seed is ${seed_max}"
CUDA_VISIBLE_DEVICES=0 python eval/eval_overcooked.py --env_name ${env} --algorithm_name ${algo} --experiment_name ${exp} --layout_name ${layout} --use_wandb True\
--user_name "ubiswas" --num_agents ${num_agents} --seed 1 --episode_length 1000 --n_eval_rollout_threads 1 --eval_episodes 2 --eval_stochastic \
--wandb_name "ubiswas" --use_wandb True --population_yaml_path ${population_yaml_path} \
--agent0_policy_name ${agent0_policy_name} \
--agent1_policy_name ${agent1_policy_name} --overcooked_version ${version} --store_traj True --cuda False