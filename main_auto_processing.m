% ������ʵ�ֶ�edf��ʽ������������Ԥ����
% Ԥ��������Ϊ��
% 1��ɾ��������ͨ��
% 2��ȫ��ƽ����reference
% 3��Ƶ���˲�
% 4���ֶΣ�tigerǰ100ms�����ߣ���ȡtigerǰ100ms����1000ms������
% ���ߣ���Ӣ�ϣ�ʱ�䣺2017,10.31

clear all
close all

[data,header] = readedf('data.edf');

channel = 1:(header.channels-1);
sr = header.samplerate(1);
%% ��ȡtrigger

trigger_num = size(data,1);%���һ�д���trigger��Ϣ
trigger  = data(65,:) - min(data(trigger_num,:));%һ����С��trigger�Ǳ�������ȥ����trigger����һ��
trigger_kind = unique(trigger);

data(65,:) = [];
%% ɾ������Ҫ��trigger�����Ե�

passthought_time = find(trigger==31);%ɾ��triggerΪ31������
data(:,passthought_time) = [];
trigger(passthought_time) = [];

%% ɾ���������ͨ��

data([20 21 26 57 58 63],:) = [];%ɾ���������ͨ�� P1 P3 PO3 P2 P4 P04 ����20��21��26��57��58��63������
channel([20 21 26 57 58 63]) = [];
%% ȫ��ƽ��reference

reference = mean(data,1);
data_ref = bsxfun(@minus,data,reference);
%% ѡ����Ҫ��ͨ��

channel_select = [22,23,24,25,27,30,31,59,60,61,62,64];
for i_channel = 1:size(channel_select,2)%�ų�֮ǰɾ��ͨ����Ӱ��
    channel_select(i_channel) = find(channel==channel_select(i_channel));
end

data_ref_select = data_ref(channel_select,:);
%% ������
rsr = 64;%��������64Hz
for i_channel = 1:size(channel_select,2)
    data_ref_select_rs(i_channel,:) = resample(data_ref_select(i_channel,:),rsr,sr);
end
trigger_rs = downsample(trigger,sr/rsr);
%% Ƶ���˲�

data_ref_select_rs_f = eegfilt(data_ref_select_rs,1,20,rsr);%��ͨ�˲�����ͨ��Ϊ1-20Hz
%% �ֶ�

i_1 = 0;i_3 = 0;i_5 = 0;i_7 = 0;i_9_10 = 0;i_even = 0;
for i_epoch = 2:size(trigger_rs,2)%�ֶ�
    
    epoch_time = i_epoch-floor(1*rsr/10):i_epoch+floor(10*rsr/10)-1;%׼���ֶ�ʱ��
    
    if (trigger_rs(i_epoch-1)==0)&&(trigger_rs(i_epoch) == 1)%��triggerΪ1������
        if i_1<90
            i_1=i_1+1;
            data_1(:,i_1,:) = data_ref_select_rs_f(:,epoch_time);
            baseline = squeeze(mean(data_1(:,i_1,1:floor(rsr/10)),3));%ȥ����
            data_1(:,i_1,:) = bsxfun(@minus,data_1(:,i_1,:),baseline);
        end
    end
    if (trigger_rs(i_epoch-1)==0)&&(trigger_rs(i_epoch) == 3)
        if i_3<90
            i_3 = i_3+1;
            data_3(:,i_3,:) = data_ref_select_rs_f(:,epoch_time);
            baseline = squeeze(mean(data_3(:,i_3,1:floor(rsr/10)),3));
            data_3(:,i_3,:) = bsxfun(@minus,data_3(:,i_3,:),baseline);
        end
    end
    if (trigger_rs(i_epoch-1)==0)&&(trigger_rs(i_epoch) == 5)
        if i_5<90
            i_5 = i_5+1;
            data_5(:,i_5,:) = data_ref_select_rs_f(:,epoch_time);
            baseline = squeeze(mean(data_5(:,i_5,1:floor(rsr/10)),3));
            data_5(:,i_5,:) = bsxfun(@minus,data_5(:,i_5,:),baseline);
        end
    end
    if (trigger_rs(i_epoch-1)==0)&&(trigger_rs(i_epoch) == 7)
        if i_7<90
            i_7=i_7+1;
            data_7(:,i_7,:) = data_ref_select_rs_f(:,epoch_time);
            baseline = squeeze(mean(data_7(:,i_7,1:floor(rsr/10)),3));
            data_7(:,i_7,:) = bsxfun(@minus,data_7(:,i_7,:),baseline);
        end
    end
    if (trigger_rs(i_epoch-1)==0)&&((trigger_rs(i_epoch)==9)||(trigger_rs(i_epoch)==10))
        if i_9_10<90
            i_9_10 = i_9_10+1;
            data_9_10(:,i_9_10,:) = data_ref_select_rs_f(:,epoch_time);
            baseline = squeeze(mean(data_9_10(:,i_9_10,1:floor(rsr/10)),3));
            data_9_10(:,i_9_10,:) = bsxfun(@minus,data_9_10(:,i_9_10,:),baseline);
        end
    end
    if (trigger_rs(i_epoch-1)==0)&&((trigger_rs(i_epoch)==2)||(trigger_rs(i_epoch)==4)||(trigger_rs(i_epoch)==6)||(trigger_rs(i_epoch)==8))
        if i_even<40
            i_even = i_even+1;
            data_even(:,i_even,:) = data_ref_select_rs_f(:,epoch_time);
            baseline = squeeze(mean(data_even(:,i_even,1:floor(rsr/10)),3));
            data_even(:,i_even,:) = bsxfun(@minus,data_even(:,i_even,:),baseline);
        end
    end
    clear baseline
end
