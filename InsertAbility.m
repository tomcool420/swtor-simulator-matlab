function [ rot ] = InsertAbility( rot,ability,location )
%INSERTABILITY Summary of this function goes here
%   Detailed explanation goes here
    rot={rot{1:location-1},ability,rot{location:end}};
end

